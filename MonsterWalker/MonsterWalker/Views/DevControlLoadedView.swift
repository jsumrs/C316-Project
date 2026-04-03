import SwiftUI
import SwiftData

struct DevControlLoadedView: View {
    @Bindable var monster: MonsterModel
    @State private var isExpanded: Bool = false
    @State private var offset: CGSize = CGSize(width: 0, height: 100)
    @State private var dragStart: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                EnergyView(energy: monster.energy)
                HStack {
                    Button("Feed") { monster.feed() }
                    Button("Pet") { monster.pet() }
                }
                .buttonStyle(CustomButtonStyle())
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Dev Controls")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 10 : 10))
                .onTapGesture {
                    withAnimation(.spring(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    DevStatControlView(monster: monster)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(width: 280)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 8)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = CGSize(
                            width: dragStart.width + gesture.translation.width,
                            height: dragStart.height + gesture.translation.height
                        )
                    }
                    .onEnded { _ in
                        dragStart = offset
                    }
            )
        }
        .task {
            await monster.start()
        }
    }
}
