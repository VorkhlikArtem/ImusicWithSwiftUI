//
//  Library.swift
//  iMusicApp
//
//  Created by Артём on 28.11.2022.
//

import SwiftUI
import URLImage

struct Library: View {
    @State var tracks = UserDefaults.standard.getSavedTracks()
    @State private var showingAlert = false
    @State private var track: SearchViewModel.Cell!
    
    var tabBarDelegate: MainTabBarControllerDelegate?
    
    var body: some View {
        
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button {
                            guard !tracks.isEmpty else {return}
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximizeTrackDetailController(cellViewModel: self.track)
                        } label: {
                            Image(systemName: "play.fill")
                                .frame(width: abs(geometry.size.width / 2 - 10), height: 50)
                                .tint(.init(.red))
                                .background(Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                .cornerRadius(10)
                                
                        }
                        
                        Button {
                            self.tracks = UserDefaults.standard.getSavedTracks()
                        } label: {
                            Image(systemName: "arrow.2.circlepath")
                                .frame(width: abs(geometry.size.width / 2 - 10), height: 50)
                                .tint(.init(.red))
                                .background(Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                .cornerRadius(10)
                        }
                      
                    }
                }.frame(height: 50).padding(.leading).padding(.trailing)
                
                Divider().padding(.leading).padding(.trailing)
                
                List {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track).gesture(LongPressGesture().onEnded({ _ in
                            self.track = track
                            self.showingAlert = true
                        }).simultaneously(with: TapGesture().onEnded({ _ in
                            
                            let keyWindow = UIApplication.shared.connectedScenes
                                .filter{$0.activationState == .foregroundActive}
                                .map{$0 as? UIWindowScene}
                                .compactMap{$0}
                                .first?.windows
                                .filter{$0.isKeyWindow}.first
                            let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                            tabBarVC?.trackDetailView.delegate = self
                                
                            self.track = track
                            self.tabBarDelegate?.maximizeTrackDetailController(cellViewModel: self.track)
                        }) ))
                    }.onDelete(perform: delete)
                }.padding(.init(top: 0, leading: 0, bottom: 20, trailing: 0))
                
            }.actionSheet(isPresented: $showingAlert, content: {
                ActionSheet(title: Text("Areyou sure to delete this track"), buttons: [
                    .destructive(Text("Delete"), action: {
                        self.delete(track: self.track)
                    }),
                    .cancel()])
            })
            
            .navigationTitle("Library")
        }
        
    }
    
    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favoriteTracksKey)
        }
    }
    
    func delete(track: SearchViewModel.Cell) {
        guard let index = tracks.firstIndex(of: track) else {return}
        tracks.remove(at: index)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favoriteTracksKey)
        }
    }
}

struct LibraryCell: View {
    var cell: SearchViewModel.Cell

    var body: some View {
        HStack {
            URLImage(URL(string: cell.iconUrlString ?? "")!) { image in
                image.resizable().frame(width: 60, height: 60).cornerRadius(2)
            }
            VStack(alignment: .leading) {
                Text("\(cell.trackName)")
                Text("\(cell.artistName)").foregroundColor(.gray)
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}


extension Library: TrackMovingDelegate {
    func moveBackForPreviosTrack() -> SearchViewModel.Cell? {
        guard let index = tracks.firstIndex(of: track) else {return nil}
        var previousTrack: SearchViewModel.Cell
        if index - 1 == -1 {
            previousTrack = tracks[tracks.count - 1]
        } else {
            previousTrack = tracks[index - 1]
        }
        self.track = previousTrack
        return previousTrack
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        guard let index = tracks.firstIndex(of: track) else {return nil}
        var nextTrack: SearchViewModel.Cell
        if index + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[index + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    
}
