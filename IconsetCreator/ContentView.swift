//
//  ContentView.swift
//  IconsetCreator
//
//  Created by Mark Erbaugh on 11/4/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
}

struct ContentView: View {
    @State private var image: NSImage?
    @State private var useMac = true
    @State private var useiPad = true
    @State private var useiPhone = true
    @State private var destination: URL?
    @State private var source: URL?
    
    @State private var alertToShow: IdentifiableAlert?
    
    private func showErrorAlert(error: Error) {
        alertToShow = IdentifiableAlert(id: "try failure", alert: {
            Alert(
                title: Text("Error Caught"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        })
    }
        
    static let desktopURL = FileManager.default.urls(for: .desktopDirectory,
                                                     in: .userDomainMask).first

    var body: some View {
        VStack(alignment: .center) {
            Image(nsImage: image ?? NSImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            Button("image")
            {
                selectImage()
            }
            Divider()
            Button("destination") {
                selectDestination()
            }
            Text(destination?.path ?? " ")
                .font(.caption)
            Divider()
            Text("Sizes for:")
                .font(.caption)
            HStack {
                Toggle("Mac",isOn: $useMac)
                Toggle("iPad", isOn: $useiPad)
                Toggle("iPhone", isOn: $useiPhone)
            }
            Divider()
            Button("create") {
                createImageSet()
            }
            .padding(.bottom, 10)
            .alert(item: $alertToShow) {alertToShow in
                alertToShow.alert()
            }
            .disabled(!(useMac || useiPad || useiPhone) || image == nil || destination == nil)
        }
        .frame(maxWidth: 300)
    }
    
    func selectImage() {
        self.image = nil
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.treatsFilePackagesAsDirectories = false
        if panel.runModal() == .OK, let url = panel.url, let image = NSImage(contentsOf: url) {
            self.image = image
            source = url
        }
    }
    
    func selectDestination() {
        destination = nil
        let panel = NSSavePanel()
        panel.showsTagField = false
        panel.nameFieldStringValue = /* source?.lastPathComponent ?? */  "AppIcon"
        panel.directoryURL = ContentView.desktopURL
        panel.nameFieldLabel = "Folder"
        panel.allowedContentTypes = [UTType.appiconset]
        if panel.runModal() == .OK, let url = panel.url {
            destination = url
        }
    }
    
    func createImageSet() {
        if let image = image, let destination = destination, useMac || useiPad || useiPhone {
            let makeIconSet = IconSet(useMac: useMac, useiPad: useiPad, useiPhone: useiPhone, image: image, destination: destination)
            do {
                try makeIconSet.make()
                self.image = nil
                self.destination = nil
            } catch {
                showErrorAlert(error: error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
