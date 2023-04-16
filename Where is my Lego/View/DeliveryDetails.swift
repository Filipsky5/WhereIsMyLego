//
//  DeliveryDetails.swift
//  Where is my Lego
//
//  Created by Filip Jabłoński on 02/04/2023.
//

import SwiftUI

struct DeliveryDetails: View {
    @StateObject var viewModel: DeliveryDetailsViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Set Details")) {
                LabeledContent("Name:", content: {
                    TextField("Batmobile", text: $viewModel.setName)
                    
                }).disabled(viewModel.editMode)
                
                DatePicker("Time:", selection: $viewModel.deliveryDate, displayedComponents: .hourAndMinute)
                LabeledContent("Set Number:", content: {
                    TextField("1756435", text: $viewModel.setNumber).keyboardType(.numberPad)
                    
                }).disabled(viewModel.editMode)
                LabeledContent("Distance:", content: {
                    TextField("2000", text: $viewModel.distance).keyboardType(.numberPad)
                    
                })
                Toggle("Token Mode:", isOn: $viewModel.isTokenEnabled)
                if !viewModel.token.isEmpty {
                    LabeledContent("Token:", content: {
                        Text(viewModel.token).textSelection(.enabled)
                    })
                }
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button(viewModel.actionButtonTitle, action: {
                        viewModel.saveOrAdd()
                    })
                }
            }
        }
        .navigationBarTitle(viewModel.navigationTitle)
    }
}

struct DeliveryDetails_Previews: PreviewProvider {
    static var previews: some View {
        DeliveryDetails(viewModel: DeliveryDetailsViewModel())
    }
}


