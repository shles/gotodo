//
//  TodoEditorView.swift
//  GoToDo
//
//  Created by Артeмий Шлесберг on 06.04.2022.
//

import SwiftUI
import CodeEditor

struct TodoEditorView: View {
    
  #if os(macOS)
    @AppStorage("fontsize") var fontSize = Int(NSFont.systemFontSize)
  #endif
    @State private var source: String // = "let a = 42"
    @State private var language = CodeEditor.Language.swift
    @State private var theme = CodeEditor.ThemeName.ocean
    
    var title: String
    
    init(title: String, code: String) {
        self.title = title
        source = code
    }

  var body: some View {
      VStack(alignment: .leading, spacing: 10) {
        Text(title)
            .font(.title)
            .padding()
    
      #if os(macOS)
        CodeEditor(source: $source, language: language, theme: theme,
                   fontSize: .init(get: { CGFloat(fontSize)  },
                                   set: { fontSize = Int($0) }))
          .frame(minWidth: 640, minHeight: 480)
      #else
        CodeEditor(source: $source, language: language, theme: theme)
      #endif
    }
      .background()
  }
}

struct TodoEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TodoEditorView(title: "Create code editor", code: codeString)
    }
}


let codeString = """

                ForEach(tasks, id: self) { item in
                    NavigationLink {
                        //TODO: create code editor
                        CodeEditor(
                            source: item.context.contextDescription.string,
                            language: .swift
                        )
                    } label: {
                        Text(item.body).font(.headline)
                    }
                }
                .onDelete(perform: deleteItems)

"""
