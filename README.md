> *其他语言版本：[简体中文](README.zh.md)*

This page introduces how to run the iOS sample project.

## Prerequisites 

- Make sure you have made the preparations mentioned in the  [Agora Meeting Guide](https://github.com/AgoraIO-Usecase/AgoraMeeting).
- Prepare the development environment:
  - Xcode 10.0 or later
  - CocoaPods

- Real iOS devices, such as iPhone or iPad.

## Run the sample project

Follow these steps to run the sample project:

1.Clone the repository to your local machine.

```
git clone https://github.com/AgoraIO-Community/eConferencing-iOS
```

2.Enter the directory of the Android project.

```
cd eConferencing-iOS
```

3.Setup sdk.

```
sh install.sh
```

4.Install dependencies.

```
pod install
```

4.Open the iOS project 

```
open VideoConference.xcworkspace
```

5.Configure parameters

Pass the following parameters in `KeyCenter.m`:

- The Agora App ID that you get.
- The `Authorization` parameter that you have generated for basic HTTP authentication.

For details, see the [prerequisites](https://github.com/AgoraIO-Usecase/AgoraMeeting#prerequisites) in Agora Meeting Guide.

```
+ (NSString *)agoraAppid {
     return <#Your Agora App Id#>;
}

+ (NSString *)authorization {
     return <#Your Authorization#>;
}

```

6. Run the project with `command + r`.

## Connect us

- You can read the full set of documentations and API reference at [Agora Developer Portal](https://docs.agora.io/en/).
- You can ask for technical support by submitting tickets in [Agora Console](https://dashboard.agora.io/). 
- You can submit an [issue](https://github.com/AgoraIO-Usecase/AgoraMeeting/issues) if you find any bug in the sample project. 

## License

Distributed under the MIT License. See `LICENSE` for more information.
