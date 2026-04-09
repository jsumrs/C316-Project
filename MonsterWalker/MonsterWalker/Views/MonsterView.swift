import SwiftData
import SwiftUI

// MARK: - MonsterView

struct MonsterView: View {
    @Environment(\.modelContext) private var context
    @Query private var monsters: [MonsterModel]
    @State private var monsterModel: MonsterModel? = nil
    @State private var showStats = false

    // Animation values for catch-up playback
    @State private var displayedEnergy: Double = 0
    @State private var displayedExp: Int64 = 0
    @State private var displayedExpCap: Int64 = 0
    @State private var isCatchingUp = false

    var body: some View {
        Group {
            if let monster = monsterModel {
                VStack {
                    InfoPlate(monster)
                    MonsterSpriteView(
                        evolutionIndex: monster.experienceComponent
                            .evolutionIndex
                        evolutionIndex: monster.experienceComponent.evolutionIndex,
                        onTap: monster.pet
                    )
                    .padding()
                    .onTapGesture {
                        monster.pet()
                    }
                    EnergyView(
                        energy: isCatchingUp ? displayedEnergy : monster.energy
                    )
                    Button("Feed") {
                        monster.feed()
                    }
                    .buttonStyle(CustomButtonStyle())
                    Button("Stats") { showStats = true }
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .padding()
                }
                .backgroundStyle(Theme.background)
                .sheet(isPresented: $showStats) {
                    StatView(monster: monster)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            let monster: MonsterModel
            if let existing = monsters.first {
                monster = existing
            } else {
                let newMonster = MonsterModel(happiness: 50, energy: 100)
                context.insert(newMonster)
                do {
                    try context.save()  // Explicit save to ensure persistence.
                } catch {
                    print("Failed to save new monster: \(error)")
                }
                monster = newMonster
            }
            monsterModel = monster
            Task {
                // Snapshot for catch-up animation
                let preEnergy = monster.energy
                let preExp = monster.experienceComponent.exp
                let preExpCap = monster.experienceComponent.expCap

                print("starting monster")
                await monsterModel?.start()
                print("monster started")

                let postEnergy = monster.energy
                let postExp = monster.experienceComponent.exp
                let postExpCap = monster.experienceComponent.expCap

                let energyChanged = abs(postEnergy - preEnergy) > 0.01
                let expChanged = postExp != preExp

                guard energyChanged || expChanged else { return }  // No change, return

                displayedEnergy = preEnergy
                displayedExp = preExp
                displayedExpCap = preExpCap
                isCatchingUp = true

                withAnimation(.easeOut(duration: 1.5)) {
                    displayedEnergy = postEnergy
                    displayedExp = postExp
                    displayedExpCap = postExpCap
                }

                try? await Task.sleep(for: .seconds(1.6))  // Wait for task to finish animating
                isCatchingUp = false
            }
        }
    }

    // MARK: - Info Plate

    func InfoPlate(_ monster: MonsterModel) -> some View {
        let exp = isCatchingUp ? displayedExp : monster.experienceComponent.exp
        let expCap =
            isCatchingUp ? displayedExpCap : monster.experienceComponent.expCap
        return VStack(spacing: Theme.xs) {
            // MARK: Name and Level Container
            HStack(alignment: .center, spacing: Theme.sm) {
                Text("Trogdor the Burninator")
                    .font(Theme.indieflower.scaled(by: 0.75))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: Level and Steps Container
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Lv. \(monster.experienceComponent.level)")
                        .font(Theme.indieflower.scaled(by: 0.55))
                    Text(
                        "\(monster.experienceComponent.getStepsToNextLevel()) steps to go"
                    )
                    .font(Theme.indieflower.scaled(by: 0.45))
                }
                .frame(width: 110, alignment: .trailing)
                .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, Theme.sm)
            .padding(.top, Theme.xs)

            // MARK: Experience Bar
            ProgressView(value: Double(exp), total: Double(expCap))
                .tint(Theme.primary)
                .animation(.easeOut(duration: 5), value: exp)
                .padding(.horizontal, Theme.sm)
                .padding(.bottom, Theme.xs)
        }
        .background(Theme.secondary)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .strokeBorder(.black.opacity(0.3), lineWidth: 0.5)
        )
        .overlay(
            Image("SketchBorder")
                .resizable()
        )
        .padding(.horizontal, Theme.sm)
        .rotationEffect(Angle(degrees: -1))
    }

    func Monster(_ expComponent: Experience) -> some View {
        // Expects asset to be "Evo_<level>" with <level> being a 0 indexed number
        Image("Evo_\(expComponent.evolutionIndex)")

    }
}

struct MonsterSpriteView: View {
    let evolutionIndex: Int
    let onTap: () -> Void

    // Snapshot variables for evolution animation
    @State private var displayedIndex: Int
    @State private var flashOpacity: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var isBouncing = false

    init(evolutionIndex: Int, onTap: @escaping () -> Void) {
        self.evolutionIndex = evolutionIndex
        self.onTap = onTap
        self._displayedIndex = State(initialValue: evolutionIndex)
    }

    var body: some View {
        Image("Evo_\(displayedIndex)")
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .overlay(Color.white.opacity(flashOpacity))
            .onTapGesture {
                guard !isBouncing else { return }
                onTap()
                bounce()
            }
            .onChange(of: evolutionIndex) { _, newIndex in
                guard newIndex != displayedIndex else { return }
                evolve(to: newIndex)
            }
    }
    
    private func bounce() {
        isBouncing = true
        withAnimation(.easeOut(duration: 0.15)) {
            scale = 1.2
        }
        Task {
            try? await Task.sleep(for: .seconds(0.15))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                scale = 1.0
            }
            try? await Task.sleep(for: .seconds(0.4))
            isBouncing = false
        }
    }

    private func evolve(to newIndex: Int) {
        // Flash white and scale up
        withAnimation(.easeIn(duration: 1.2)) {
            flashOpacity = 1.0
            scale = 1.2
        }

        // Run the sprite change on the main thread after a delay
        Task {
            try? await Task.sleep(for: .seconds(1.3))
            displayedIndex = newIndex
            withAnimation(.easeOut(duration: 1.0)) {
                flashOpacity = 0
                scale = 1.0
            }
        }
    }
}

#Preview {
    MonsterView()
}
