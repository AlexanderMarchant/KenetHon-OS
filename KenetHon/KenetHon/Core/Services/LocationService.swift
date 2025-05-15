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

import CoreLocation
import Combine

final class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager: CLLocationManager
    
    private let currentLocationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    private let authorizationStatusSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    
    var currentLocation: AnyPublisher<CLLocation?, Never> {
        return currentLocationSubject.eraseToAnyPublisher()
    }
    
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        return authorizationStatusSubject.eraseToAnyPublisher()
    }
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        self.authorizationStatusSubject.value = locationManager.authorizationStatus
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoringLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopMonitoringLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatusSubject.value = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            currentLocationSubject.value = loc
        }
    }
}
