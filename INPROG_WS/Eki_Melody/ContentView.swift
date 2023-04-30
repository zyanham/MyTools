//
//  ContentView.swift
//  SoundSwitch
//
//  Created by Yujiro Kaneko on 2022/12/03.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    private let Sound_A1 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Kawasaki_kawasakishikaA")!.data)
    private let Sound_A2 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Kawasaki_KawasakishikaB")!.data)
    private let Sound_A3 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Kashimada_in_DanceOn")!.data)
    private let Sound_A4 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Kashimada_out_SunnyIslands")!.data)
    private let Sound_A5 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Noborito_No1_bokudoraemon")!.data)
    private let Sound_A6 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_noborito_No2_kiteyoperman")!.data)
    private let Sound_A7 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_noborito_No3_doraemonnouta")!.data)

    private let Sound_B1 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Shukugawara_in_YumewokanaeteDoraemon")!.data)
    private let Sound_B2 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Shukugawara_out_suiminbusoku")!.data)
    private let Sound_B3 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_musashikosugi_in_nanbawanyaro")!.data)
    private let Sound_B4 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_musashishinjo_JR_SH2-1")!.data)
    private let Sound_B5 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_musashishinjo_JR_SH5-1")!.data)
    private let Sound_B6 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Shinkawasaki_in_susukinokogenV1")!.data)
    private let Sound_B7 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Shinkawasaki_out_Airy")!.data)

    private let Sound_C1 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Ebisu_DaisannootokoE")!.data)
    private let Sound_C2 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Ebisu_DaisannootokoF")!.data)
    private let Sound_C3 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Chigasaki_KibonowadachiAmero")!.data)
    private let Sound_C4 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Chigasaki_KibonowadachiSabi")!.data)
    private let Sound_C5 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Odawara_OsarunokagoyaV2")!.data)
    private let Sound_C6 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Odawara_OsarunokagoyaV1")!.data)
    private let Sound_C7 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_TM_HibiyaSen_Ginza_No.5")!.data)

    private let Sound_D1 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_odakyu_noborito_in_yumewokanaetedoraemon")!.data)
    private let Sound_D2 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_odakyu_noborito_out_kiteyoperman")!.data)
    private let Sound_D3 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_odakyu_mukogaokayuen_in_doraemonnouta")!.data)
    private let Sound_D4 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_odakyu_mukogaokayuen_out_hajimetenochu")!.data)
    private let Sound_D5 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_odakyu_ebina_in_SAKURA_intro")!.data)
    private let Sound_D6 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_odakyu_ebina_out_SAKURA_main")!.data)
    private let Sound_D7 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_TM_HibiyaSen_Ginza_No.6")!.data)

    private let Sound_E1 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_Odakyu_Sosigayaokura_Urutoraman")!.data)
    private let Sound_E2 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_Odakyu_Sosigayaokura_Urutorasebun")!.data)
    private let Sound_E3 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_Odakyu_Honatsugi_YELLintro")!.data)
    private let Sound_E4 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_Odakyu_Honatsugi_YELLsabi")!.data)
    private let Sound_E5 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_Odakyu_Shibusawa_Makenaide")!.data)
    private let Sound_E6 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_Odakyu_Shibusawa_Yureruomoi")!.data)
    private let Sound_E7 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_Keio_TamaCenter_out_Pyuroland")!.data)

    private let Sound_F1 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_enoden_fujisawa_sukidesuenoden")!.data)
    private let Sound_F2 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_enoden_kamakura")!.data)
    private let Sound_F3 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_motosumiyoshi_FRONTALERABBIT")!.data)
    private let Sound_F4 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_sotetsu_kidsstation")!.data)
    private let Sound_F5 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Maihama_in_It_s-a-smallworld")!.data)
    private let Sound_F6 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_JR_Maihama_out_Zip-A-Dee_Doo_Dah")!.data)
    private let Sound_F7 =  try! AVAudioPlayer(data: NSDataAsset(name: "SE_KeioTamacenter_pyuromarch")!.data)

    
    private func playSound_A1(){
        Sound_A1.stop()
        Sound_A1.currentTime = 0.0
        Sound_A1.play()
    }
    private func playSound_A2(){
        Sound_A2.stop()
        Sound_A2.currentTime = 0.0
        Sound_A2.play()
    }
    private func playSound_A3(){
        Sound_A3.stop()
        Sound_A3.currentTime = 0.0
        Sound_A3.play()
    }
    private func playSound_A4(){
        Sound_A4.stop()
        Sound_A4.currentTime = 0.0
        Sound_A4.play()
    }
    private func playSound_A5(){
        Sound_A5.stop()
        Sound_A5.currentTime = 0.0
        Sound_A5.play()
    }
    private func playSound_A6(){
        Sound_A6.stop()
        Sound_A6.currentTime = 0.0
        Sound_A6.play()
    }
    private func playSound_A7(){
        Sound_A7.stop()
        Sound_A7.currentTime = 0.0
        Sound_A7.play()
    }

    private func playSound_B1(){
        Sound_B1.stop()
        Sound_B1.currentTime = 0.0
        Sound_B1.play()
    }
    private func playSound_B2(){
        Sound_B2.stop()
        Sound_B2.currentTime = 0.0
        Sound_B2.play()
    }
    private func playSound_B3(){
        Sound_B3.stop()
        Sound_B3.currentTime = 0.0
        Sound_B3.play()
    }
    private func playSound_B4(){
        Sound_B4.stop()
        Sound_B4.currentTime = 0.0
        Sound_B4.play()
    }
    private func playSound_B5(){
        Sound_B5.stop()
        Sound_B5.currentTime = 0.0
        Sound_B5.play()
    }
    private func playSound_B6(){
        Sound_B6.stop()
        Sound_B6.currentTime = 0.0
        Sound_B6.play()
    }
    private func playSound_B7(){
        Sound_B7.stop()
        Sound_B7.currentTime = 0.0
        Sound_B7.play()
    }

    private func playSound_C1(){
        Sound_C1.stop()
        Sound_C1.currentTime = 0.0
        Sound_C1.play()
    }
    private func playSound_C2(){
        Sound_C2.stop()
        Sound_C2.currentTime = 0.0
        Sound_C2.play()
    }
    private func playSound_C3(){
        Sound_C3.stop()
        Sound_C3.currentTime = 0.0
        Sound_C3.play()
    }
    private func playSound_C4(){
        Sound_C4.stop()
        Sound_C4.currentTime = 0.0
        Sound_C4.play()
    }
    private func playSound_C5(){
        Sound_C5.stop()
        Sound_C5.currentTime = 0.0
        Sound_C5.play()
    }
    private func playSound_C6(){
        Sound_C6.stop()
        Sound_C6.currentTime = 0.0
        Sound_C6.play()
    }
    private func playSound_C7(){
        Sound_C7.stop()
        Sound_C7.currentTime = 0.0
        Sound_C7.play()
    }

    private func playSound_D1(){
        Sound_D1.stop()
        Sound_D1.currentTime = 0.0
        Sound_D1.play()
    }
    private func playSound_D2(){
        Sound_D2.stop()
        Sound_D2.currentTime = 0.0
        Sound_D2.play()
    }
    private func playSound_D3(){
        Sound_D3.stop()
        Sound_D3.currentTime = 0.0
        Sound_D3.play()
    }
    private func playSound_D4(){
        Sound_D4.stop()
        Sound_D4.currentTime = 0.0
        Sound_D4.play()
    }
    private func playSound_D5(){
        Sound_D5.stop()
        Sound_D5.currentTime = 0.0
        Sound_D5.play()
    }
    private func playSound_D6(){
        Sound_D6.stop()
        Sound_D6.currentTime = 0.0
        Sound_D6.play()
    }
    private func playSound_D7(){
        Sound_D7.stop()
        Sound_D7.currentTime = 0.0
        Sound_D7.play()
    }

    private func playSound_E1(){
        Sound_E1.stop()
        Sound_E1.currentTime = 0.0
        Sound_E1.play()
    }
    private func playSound_E2(){
        Sound_E2.stop()
        Sound_E2.currentTime = 0.0
        Sound_E2.play()
    }
    private func playSound_E3(){
        Sound_E3.stop()
        Sound_E3.currentTime = 0.0
        Sound_E3.play()
    }
    private func playSound_E4(){
        Sound_E4.stop()
        Sound_E4.currentTime = 0.0
        Sound_E4.play()
    }
    private func playSound_E5(){
        Sound_E5.stop()
        Sound_E5.currentTime = 0.0
        Sound_E5.play()
    }
    private func playSound_E6(){
        Sound_E6.stop()
        Sound_E6.currentTime = 0.0
        Sound_E6.play()
    }
    private func playSound_E7(){
        Sound_E7.stop()
        Sound_E7.currentTime = 0.0
        Sound_E7.play()
    }

    private func playSound_F1(){
        Sound_F1.stop()
        Sound_F1.currentTime = 0.0
        Sound_F1.play()
    }
    private func playSound_F2(){
        Sound_F2.stop()
        Sound_F2.currentTime = 0.0
        Sound_F2.play()
    }
    private func playSound_F3(){
        Sound_F3.stop()
        Sound_F3.currentTime = 0.0
        Sound_F3.play()
    }
    private func playSound_F4(){
        Sound_F4.stop()
        Sound_F4.currentTime = 0.0
        Sound_F4.play()
    }
    private func playSound_F5(){
        Sound_F5.stop()
        Sound_F5.currentTime = 0.0
        Sound_F5.play()
    }
    private func playSound_F6(){
        Sound_F6.stop()
        Sound_F6.currentTime = 0.0
        Sound_F6.play()
    }
    private func playSound_F7(){
        Sound_F7.stop()
        Sound_F7.currentTime = 0.0
        Sound_F7.play()
    }

    
    var body: some View {
        HStack{
            Button(action: {
                playSound_A1()
            }) {
                VStack{
                    Image("IMG_JN01_Kawasaki_No5")
                }
            }

            Button(action: {
                playSound_A2()
            }) {
                VStack{
                    Image("IMG_JN01_Kawasaki_No6")
                }
            }

            Button(action: {
                playSound_A3()
            }) {
                VStack{
                    Image("IMG_JN04_Kashimada_in")
                }
            }

            Button(action: {
                playSound_A4()
            }) {
                VStack{
                    Image("IMG_JN04_Kashimada_out")
                }
            }

            Button(action: {
                playSound_A5()
            }) {
                VStack{
                    Image("IMG_JN14_Noborito_No1")
                }
            }

            Button(action: {
                playSound_A6()
            }) {
                VStack{
                    Image("IMG_JN14_Noborito_No2")
                }
            }

            Button(action: {
                playSound_A7()
            }) {
                VStack{
                    Image("IMG_JN14_Noborito_No3")
                }
            }

        }

        HStack{
            Button(action: {
                playSound_B1()
            }) {
                VStack{
                    Image("IMG_JN13_Shukugawara_in")
                }
            }
            Button(action: {
                playSound_B2()
            }) {
                VStack{
                    Image("IMG_JN13_Shukugawara_out")
                }
            }
            Button(action: {
                playSound_B3()
            }) {
                VStack{
                    Image("IMG_JN07_Musashikosugi_in")
                }
            }
            Button(action: {
                playSound_B4()
            }) {
                VStack{
                    Image("IMG_JN09_Musashishinjo_in")
                }
            }
            Button(action: {
                playSound_B5()
            }) {
                VStack{
                    Image("IMG_JN09_Musashishinjo_out")
                }
            }
            Button(action: {
                playSound_B6()
            }) {
                VStack{
                    Image("IMG_JO14_Shinkawasaki_in")
                }
            }
            Button(action: {
                playSound_B7()
            }) {
                VStack{
                    Image("IMG_JO14_Shinkawasaki_out")
                }
            }
        }
        
        HStack{
            Button(action: {
                playSound_C1()
            }) {
                VStack{
                    Image("IMG_JY21_Ebisu_sotomawari")
                }
            }
            Button(action: {
                playSound_C2()
            }) {
                VStack{
                    Image("IMG_JY21_Ebisu_uchimawari")
                }
            }
            Button(action: {
                playSound_C3()
            }) {
                VStack{
                    Image("IMG_JT10_Chigasaki_in")
                }
            }
            Button(action: {
                playSound_C4()
            }) {
                VStack{
                    Image("IMG_JT10_Chigasaki_out")
                }
            }

            Button(action: {
                playSound_C5()
            }) {
                VStack{
                    Image("IMG_JT16_Odawara_in")
                }
            }

            Button(action: {
                playSound_C6()
            }) {
                VStack{
                    Image("IMG_JT16_Odawara_out")
                }
            }

            Button(action: {
                playSound_C7()
            }) {
                VStack{
                    Image("IMG_H08_Ginza_No.5")
                }
            }

        }

        HStack{
            Button(action: {
                playSound_D1()
            }) {
                VStack{
                    Image("IMG_OH18_Noborito_in")
                }
            }
            Button(action: {
                playSound_D2()
            }) {
                VStack{
                    Image("IMG_OH18_Noborito_out")
                }
            }
            Button(action: {
                playSound_D3()
            }) {
                VStack{
                    Image("IMG_OH19_Mukogaokayuen_in")
                }
            }
            Button(action: {
                playSound_D4()
            }) {
                VStack{
                    Image("IMG_OH19_Mukogaokayuen_out")
                }
            }

            Button(action: {
                playSound_D5()
            }) {
                VStack{
                    Image("IMG_OH32_Ebina_in")
                }
            }

            Button(action: {
                playSound_D6()
            }) {
                VStack{
                    Image("IMG_OH32_Ebina_out")
                }
            }

            Button(action: {
                playSound_D7()
            }) {
                VStack{
                    Image("IMG_H08_Ginza_No.6")
                }
            }
        }

        
        HStack{
            Button(action: {
                playSound_E1()
            }) {
                VStack{
                    Image("IMG_OH13_Sosigayaokura_in")
                }
            }
            Button(action: {
                playSound_E2()
            }) {
                VStack{
                    Image("IMG_OH13_Sosigayaokura_out")
                }
            }
            Button(action: {
                playSound_E3()
            }) {
                VStack{
                    Image("IMG_OH34_Honatsugi_no34")
                }
            }
            Button(action: {
                playSound_E4()
            }) {
                VStack{
                    Image("IMG_OH34_Honatsugi_no12")
                }
            }

            Button(action: {
                playSound_E5()
            }) {
                VStack{
                    Image("IMG_OH40_Shibusawa_in")
                }
            }

            Button(action: {
                playSound_E6()
            }) {
                VStack{
                    Image("IMG_OH40_Shibusawa_out")
                }
            }

            Button(action: {
                playSound_E7()
            }) {
                VStack{
                    Image("IMG_KO41_KeioTamacenter_out")
                }
            }

        }

        HStack{
            Button(action: {
                playSound_F1()
            }) {
                VStack{
                    Image("IMG_EN01_Fujisawa")
                }
            }
            Button(action: {
                playSound_F2()
            }) {
                VStack{
                    Image("IMG_EN15_Kamakura")
                }
            }

            Button(action: {
                playSound_F3()
            }) {
                VStack{
                    Image("IMG_TY12_Motosumiyoshi")
                }
            }

            Button(action: {
                playSound_F4()
            }) {
                VStack{
                    Image("IMG_SO51_Hazawayokohamakokudai")
                }
            }

            Button(action: {
                playSound_F5()
            }) {
                VStack{
                    Image("IMG_JE07_Maihama_in")
                }
            }

            Button(action: {
                playSound_F6()
            }) {
                VStack{
                    Image("IMG_JE07_Maihama_out")
                }
            }

            Button(action: {
                playSound_F7()
            }) {
                VStack{
                    Image("IMG_KO41_KeioTamacenter_in")
                }
            }

        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
