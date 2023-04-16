//
//  ContentView.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 02/04/2023.
//

import SwiftUI

struct LiveActivitiesList: View {
    @ObservedObject var viewModel: LiveActivitiesListViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.deliveries, id: \.self) { item in
                        NavigationLink(destination: DeliveryDetails(viewModel: DeliveryDetailsViewModel(legoDelivery: item))) {
                            Text(item.setName)
                        }
                    }
                    .onDelete(perform: viewModel.removeItems)
                }
                Button("Submit tasks") {}
                Spacer()
            }
            .navigationBarTitle(Text("Lego Deliveries"))
            .navigationBarItems(trailing: EditButton())
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: DeliveryDetails(viewModel: DeliveryDetailsViewModel())) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.loadActivities()
            }
        }
    }
}

struct LiveActivitiesList_Previews: PreviewProvider {
    static var previews: some View {
        LiveActivitiesList(viewModel: LiveActivitiesListViewModel())
    }
}

