> *其他语言版本：[简体中文](README.zh.md)*

## Table of contents
- [About the project](https://github.com/AgoraIO-Usecase/AgoraMeeting#about-the-project)
  - [Applicable scenarios](https://github.com/AgoraIO-Usecase/AgoraMeeting#applicable-scenarios)
  - [Functions](https://github.com/AgoraIO-Usecase/AgoraMeeting#functions)
  - [Compatibility](https://github.com/AgoraIO-Usecase/AgoraMeeting#compatibility)
- [Get started](https://github.com/AgoraIO-Usecase/AgoraMeeting#get-started)
    - [Get an Agora App ID](https://github.com/AgoraIO-Usecase/AgoraMeeting#get-an-agora-app-id)
    - [Pass the basic HTTP authentication](https://github.com/AgoraIO-Usecase/AgoraMeeting#pass-the-basic-http-authentication)
    - [Get a Netless  `sdkToken` and register with Agora Conference Cloud Service](https://github.com/AgoraIO-Usecase/AgoraMeeting#get-a-netless--sdktoken-and-register-with-agora-conference-cloud-service)
  - [Run the sample project](https://github.com/AgoraIO-Usecase/AgoraMeeting#run-the-sample-project)
  - [Use Agora Conference Cloud Service](https://github.com/AgoraIO-Usecase/AgoraMeeting#use-agora-conference-cloud-service)
- [FAQ](https://github.com/AgoraIO-Usecase/AgoraMeeting#faq)

## About the project

Agora Meeting is a sample project provided by Agora that demonstrates how to use **Agora Conference Cloud Service**, **Agora RTC SDK**, **Agora RTM SDK**, **Agora Cloud Recording**, and the third-party Netless whiteboard SDK to quickly implement a basic enterprise video conferencing solution.

### Applicable scenario

Agora Meeting supports the basic video conferencing scenario. In a typical video conference, a host presides over the meeting and multiple participants share their thoughts about a topic. To make the communication more effective, both the host and participants can share their screens, mute or un-mute themselves, turn the local camera on or off, and send and receive text messages. Background blurring and image enhancement can also be used to help the participants concentrate. 

### Functions

| Feature              | Web  | iOS and Android | Description                                                  |
| :------------------- | :--- | :-------------- | :----------------------------------------------------------- |
| Real-time engagement | ✔    | ✔               | During the meeting, the host and participants engage in real-time audio and video communication. |
| Real-time messaging  | ✔    | ✔               | The host and participants can chat with each other through text messages. |
| Whiteboard           | ✔    | ✔               | The host can use the whiteboard to share a PowerPoint slide, a Word or PDF file, or even an audio or video file. The host and the participants can also write on the whiteboard collaboratively. |
| Screen sharing       | ✔    | ✘               | Both the host and the participants can share their screens with each other to make the communication more effective. |
| Meeting management   | ✔    | ✔               | The host starts or ends the meeting, and manages the participants' privilege to send audio, video, or real-time messages. |
| Invitation           | ✔    | ✔               | Invite others to the meeting. Get the title, password and link of the meeting with a single click. |

### Compatibility

 Agora Meeting supports the following platforms and versions: 

- iOS 10 or later. We do not test Agora Meeting on iOS 9 updates.
- Android 4.4 and later.
- Web Chrome 72 and later. We do not test Agora Meeting on browsers.

## Get started

### Prerequisites 

Make sure you make the following preparations before compiling and running the sample project.

#### Get an Agora App ID
Follow these steps to get an Agora App ID:
  1. Create an account in [Agora Console](https://sso.agora.io/v2/signup).
  2. Log in to Agora Console and create a project. Select **"App ID + App Certificate + Token"** as your authentication mechanism when creating the project. Make sure that you enable the [App Certificate](https://docs.agora.io/en/Agora%20Platform/token?platform=All%20Platforms#appcertificate) of this project.
  3. Get the App ID of this project in **Project Management** page.

#### Pass the basic HTTP authentication

Before using the Agora RESTful APIs, you need to generate the `Authorization` parameter with the Customer ID and Customer Certificate provided by Agora and pass the `Authorization` parameter in the HTTP request header for authentication. For details, see the [steps of basic HTTP authentication](https://docs.agora.io/en/faq/restful_authentication).

#### Get a Netless  `sdkToken` and register with Agora Conference Cloud Service
Follow these steps to get a Netless whiteboard  `sdkToken`:
1. Create an account in [Netless Console](https://console.herewhite.com/en/register/).
2. Log in to Netless Console and get the `sdkToken` in the **Key management** page.

You need to register the sdkToken of the whiteboard to the Agora cloud server.
1. Open [Agora Console](https://console.agora.io/)
2. Edit **Project Management**, select the function module and click "update the token" to register.

### Run the sample project

See the following documents to compile and run the sample project:

- [Run the Android project](https://github.com/AgoraIO-Usecase/AgoraMeeting/tree/master/AgoraMeeting_Android)
- [Run the iOS project](https://github.com/AgoraIO-Usecase/AgoraMeeting/tree/master/AgoraMeeting_iOS)
- [Run Web project](https://github.com/AgoraIO-Usecase/AgoraMeeting/tree/master/AgoraMeeting_web)

### Use Agora Conference Cloud Service

Agora provides Agora Conference Cloud Service for developers who are not good at back end development. You can call the RESTful APIs of Agora Conference Cloud Service to quickly implement managing the states of meeting rooms and the permissions of users on the back end. For details, see [Agora Conference Cloud Service](https://github.com/AgoraIO-Usecase/AgoraMeeting/wiki/Agora-Cloud-Service).

## FAQ

See [Troubleshooting](https://github.com/AgoraIO-Usecase/AgoraMeeting/wiki/Trouble-Shooting).
