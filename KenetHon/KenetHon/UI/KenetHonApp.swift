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

@main
struct KenetHonApp: App {
    @StateObject var locationService: LocationService = LocationService()
    var body: some Scene {
        WindowGroup {
            MapView(locationService: locationService)
        }
    }
}
