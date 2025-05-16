// Copyright (c) 2025 Alex Marchant
//
// This file is part of KenetHon.
//
// KenetHon is licensed under the Mozilla Public License, v. 2.0.
// You may obtain a copy of the License at:
//
//   http://opensource.org/licenses/MPL-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" basis,
// without warranties or conditions of any kind, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Combine
import CoreLocation

extension MapView {
    final class ViewModel: ObservableObject {
        private let locationService: LocationService
        
        private var cancellables: Set<AnyCancellable> = []
        
        @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
        @Published private(set) var addressInformation: String?
        
        init(locationService: LocationService) {
            self.locationService = locationService
            
            locationService.authorizationStatus
                .removeDuplicates()
                .receive(on: RunLoop.main)
                .sink { [weak self] auth in
                    if auth.isAuthorized {
                        self?.locationService.startMonitoringLocation()
                    } else {
                        self?.locationService.stopMonitoringLocation()
                    }
                    self?.authorizationStatus = auth
                }
                .store(in: &self.cancellables)
            
            locationService.currentLocation
                .removeDuplicates(by: { (oldValue, newValue) in
                    switch (oldValue, newValue) {
                    case (nil, nil):
                        return true
                    case (let lhs?, let rhs?):
                        // Emit values that are greater than 50M from the existing value
                        return lhs.distance(from: rhs) < 50
                    default:
                        return false
                    }
                })
                .flatMap { [weak self] location -> AnyPublisher<String?, Never> in
                    if let location = location {
                        return Future { promise in
                            Task {
                                let address = await self?.getAddressInformation(from: location)
                                promise(.success(address))
                            }
                        }
                        .eraseToAnyPublisher()
                    } else {
                        return Just(nil).eraseToAnyPublisher()
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] address in
                    self?.addressInformation = address
                }
                .store(in: &cancellables)
        }
        
        func requestLocationAuthorization() {
            locationService.requestAuthorization()
        }
        
        private func getAddressInformation(from location: CLLocation) async -> String? {
            let geoCoder = CLGeocoder()
            do {
                let placemarks = try await geoCoder.reverseGeocodeLocation(location)
                guard let placemark = placemarks.first else { return nil }

                var components: [String] = []
                if let name = placemark.name { components.append(name) }
                if let street = placemark.thoroughfare { components.append(street) }
                if let city = placemark.locality { components.append(city) }
                if let state = placemark.administrativeArea { components.append(state) }
                if let zip = placemark.postalCode { components.append(zip) }
                if let country = placemark.country { components.append(country) }

                return components.joined(separator: ", ")
            } catch {
                return nil
            }
        }
    }
}
