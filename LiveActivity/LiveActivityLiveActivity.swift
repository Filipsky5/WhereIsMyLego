//
//  LiveActivityLiveActivity.swift
//  LiveActivity
//
//  Created by Filip Jabłoński on 16/04/2023.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            VStack {
                HStack {
                    if let image = context.attributes.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    Text(context.attributes.setName)
                    Spacer()
                    Image(systemName: "clock")
                    Text("~\(context.state.deliveryTime)")
                }.padding()
                
                ProgressView(value: context.state.distanceValue).padding()
                
            }
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(context.attributes.setName)")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Image(systemName: "clock")
                        Text("~\(context.state.deliveryTime)")
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Spacer()
                    ProgressView(value: context.state.distanceValue).padding()
                }
            } compactLeading: {
                Text("\(context.attributes.setNumber)")
            } compactTrailing: {
                ProgressView(value: context.state.distanceValue)
                    .progressViewStyle(.circular)
            } minimal: {
                ProgressView(value: context.state.distanceValue)
                    .progressViewStyle(.circular)
                
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct LiveActivityLiveActivity_Previews: PreviewProvider {
    static let attributes = LiveActivityAttributes(imageURL: "", setName: "Batmobil", setNumber: 76240)
    static let contentState = LiveActivityAttributes.ContentState(deliveryTime: "45 min", distance: 2000)

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
