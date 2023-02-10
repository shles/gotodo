//
//  ContentView.swift
//  GoToDo
//
//  Created by Артeмий Шлесберг on 06.04.2022.
//

import SwiftUI
import CoreData
import CodeEditor

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var tasks: [SimpleTask] = sampleTasks
    
    @State var filename = "Filename"
    @State var showFileChooser = false

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks, id: \.self) { item in
                    NavigationLink {
                        //TODO: create code editor
                        TodoEditorView(title: item.body,code: item.context.contextDescription.string)
//                        CodeEditor(
//                            source: item.context.contextDescription.string,
//                            language: .swift
//                        )
                    } label: {
                        Text(item.body).font(.headline)
                            .lineLimit(3)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: openProject) {
                        Label("Open", systemImage: "folder")
                    }
                }
            }
            Text("Select an item")
        }
    }
    
    private func openProject() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
//            self.filename = panel.url?.lastPathComponent ?? "<none>"
            if let url = panel.url {
                self.tasks = TasksFromCode(url: url).items().map { $0 as! SimpleTask }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

private var sampleTasks: [SimpleTask] = [
    .init(body: "Highlight", context: SurroundingCodeContext(url: URL(fileURLWithPath: ""), code: """
                                                             static func highlighted(code: String) -> NSAttributedString{
                                                             //TODO: highlight
                                                     //        let highlightr = Highlightr()!
                                                     //        highlightr.setTheme(to: "ocean")"))
                                             """))
]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext )
    }
}
