//
//  ContentView.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()
    @State var mapView: GoogleMapsView? = nil
    
    var body: some View {
        ZStack {
            if mapView != nil {
                mapView
                    .ignoresSafeArea()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .frame(width: 44, height: 45, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.75, green: 0.77, blue: 0.85), lineWidth: 0.5),
                                alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/),
                        alignment: .center)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 8)
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "minus")
                            .resizable()
                            .scaledToFit()
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .frame(width: 44, height: 45, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.75, green: 0.77, blue: 0.85), lineWidth: 0.5),
                                alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/),
                        alignment: .center)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 119)
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "eye")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .frame(width: 44, height: 45, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .aspectRatio(1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.75, green: 0.77, blue: 0.85), lineWidth: 0.5),
                                alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/),
                        alignment: .center)
                }
                .padding(.trailing, 16)
                VStack {
                    VStack {
                        Text("Бензовоз")
                            .font(.system(size: 20).weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 16)
                        HStack {
                            Label(
                                title: { Text(viewModel.dateRange) },
                                icon: { Image(systemName: "calendar") }
                            )
                            .padding(.trailing, 20)
                            Spacer()
                            Label(
                                title: { Text("\(NSString(format:"%.1f", viewModel.totalDistance)) km") },
                                icon: { Image(systemName: "map") }
                            )
                            .padding(.trailing, 20)
                            Spacer()
                            Label(
                                title: { Text("До \(viewModel.maxSpeed)км/ч") },
                                icon: { Image(systemName: "gauge.with.dots.needle.67percent") }
                            )
                        }
                        .font(.system(size: 12))
                        .padding(.top, 8.5)
                        if viewModel.ditances.count > 0 {
                            Slider(value: $viewModel.slider,
                                   in: ClosedRange(uncheckedBounds: (0, Double(viewModel.ditances.count-1))),
                                   step: 1)
                            .alignmentGuide(VerticalAlignment.center) { $0[VerticalAlignment.center]}
                            .padding(.top)
                            .overlay(GeometryReader { gp in
                                Text("\(Int(viewModel.speed[Int(viewModel.slider)]))км/ч")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.74))
                                    .alignmentGuide(HorizontalAlignment.leading) {
                                        $0[HorizontalAlignment.leading] - (gp.size.width - $0.width) * viewModel.slider / ( Double(viewModel.ditances.count-1) )
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }, alignment: .top)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .ignoresSafeArea()
                .background(
                    BlurView(style: .systemUltraThinMaterialLight)
                        .border(Color(red: 0.81, green: 0.84, blue: 0.91), width: 0.5)
                        .ignoresSafeArea(),
                    alignment: .center
                )
            }
        }
        .onAppear {
            mapView = GoogleMapsView(points: $viewModel.data, speed: $viewModel.speed)
            Task {
                await viewModel.getData()
            }
        }
        .onChange(of: viewModel.data, perform: { value in
            mapView?.drawPath()
        })
    }
}

#Preview {
    ContentView()
}

//[
//    "2019-06-28T07:33:48",
//    37.61083,
//    55.65103
//],
//[
//    "2019-06-28T07:33:49",
//    37.6109316666667,
//    55.6510383333333
//],
