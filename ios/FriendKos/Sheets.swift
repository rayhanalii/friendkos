import SwiftUI

/// Sheet generik berisi form sederhana untuk menambah data.
struct FormSheet: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let fields: [(String, Binding<String>)]
    var multiline = false
    let onSave: () -> Bool

    var body: some View {
        NavigationStack {
            Form {
                ForEach(fields.indices, id: \.self) { i in
                    if multiline { TextField(fields[i].0, text: fields[i].1, axis: .vertical).lineLimit(4...8) }
                    else { TextField(fields[i].0, text: fields[i].1) }
                }
                Button("Simpan") { if onSave() { dismiss() } }.buttonStyle(PrimaryButtonStyle())
            }
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Tutup") { dismiss() } } }
        }.presentationDetents([.medium])
    }
}

struct EmptyHint: View {
    let icon: String; let text: String
    var body: some View {
        HStack(spacing: 10) { Image(systemName: icon).foregroundStyle(Theme.muted); Text(text).font(.footnote).foregroundStyle(Theme.muted) }
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 14))
    }
}
