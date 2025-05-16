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

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: ViewModel
    
    @State private var position: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .automatic
    )
    
    init(locationService: LocationService) {
        self._viewModel = StateObject(wrappedValue: ViewModel(locationService: locationService))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                if self.viewModel.authorizationStatus.isAuthorized {
                    UserAnnotation()
                }
            }
            .mapControls {
                if self.viewModel.authorizationStatus.isAuthorized {
                    MapUserLocationButton()
                }
            }
            VStack {
                switch self.viewModel.authorizationStatus {
                case .notDetermined:
                    Button(action: {
                        self.viewModel.requestLocationAuthorization()
                    }) {
                        Text("Enable Location Services")
                    }
                case .restricted:
                    Text("Location services are restricted")
                case .denied:
                    Text("Please enable location services in settings")
                case .authorizedWhenInUse, .authorizedAlways:
                    Text(self.viewModel.addressInformation ?? "Unknown")
                default:
                    Text("Please enable location services in settings")
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
            .padding(.horizontal, 25)
        }
    }
}

#Preview {
    MapView(locationService: LocationService())
}
