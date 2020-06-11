> *Read this article in another language: [English](README.md)*

## 目录
- [项目概述](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E9%A1%B9%E7%9B%AE%E6%A6%82%E8%BF%B0)
  - [支持场景](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E6%94%AF%E6%8C%81%E5%9C%BA%E6%99%AF)
  - [功能列表](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E5%8A%9F%E8%83%BD%E5%88%97%E8%A1%A8)
  - [平台兼容](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E5%B9%B3%E5%8F%B0%E5%85%BC%E5%AE%B9)
- [快速开始](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
  - [前提条件](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E5%89%8D%E6%8F%90%E6%9D%A1%E4%BB%B6)
    - [获取声网 App ID](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E8%8E%B7%E5%8F%96%E5%A3%B0%E7%BD%91-app-id)
    - [进行 HTTP 基本认证](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E8%BF%9B%E8%A1%8C-http-%E5%9F%BA%E6%9C%AC%E8%AE%A4%E8%AF%81)
    - [获取第三方白板 SDK Token 并注册到 Agora 会议云服务](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E6%8E%A5%E5%85%A5-agora-%E4%BC%9A%E8%AE%AE%E4%BA%91%E6%9C%8D%E5%8A%A1)
  - [运行示例项目](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E8%BF%90%E8%A1%8C%E7%A4%BA%E4%BE%8B%E9%A1%B9%E7%9B%AE)
  - [接入 Agora 会议云服务](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#接入-agora-会议云服务)
- [常见问题](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/README.zh.md#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)

## 项目概述

Agora Meeting 是声网专为企业视频会议提供的示例项目，演示了如何通过 Agora 会议云服务，并配合 Agora RTC SDK、Agora RTM SDK 和第三方 Netless 白板 SDK，快速实现基本的视频会议场景。

### 支持场景

Agora Meeting 示例项目提供典型视频会议功能。一个典型的视频会议包括一个会议主持人，N 个与会人；主讲人主持会议，与会人依次发表对该议题的看法，或同时发言进行讨论。为达到最佳会议效果，主持人和与会人在会议过程中，可以进行屏幕共享、静音、关闭本地摄像头、收发文字消息等操作，甚至还可以进行背景替换、背景虚化、美颜等功能，增进沟通氛围。

### 功能列表

| 功能       | Web  | iOS 和 Android | 描述                                                         |
| :--------- | :--- | :------------- | :----------------------------------------------------------- |
| 实时音视频 | ✔    | ✔              | 会议主持人和与会人进行实时音视频互动。                       |
| 实时消息   | ✔    | ✔              | 主持人和与会人在会议过程中发送实时文字消息进行互动。         |
| 互动白板   | ✔    | ✔              | 主持人在白板上涂鸦、上传文件（PPT、Word 和 PDF）或播放视频。 |
| 屏幕共享   | ✔    | ✘              | 主持人或与会人将自己屏幕的内容分享给其他同事观看，提高沟通效率。 |
| 会议管理   | ✔    | ✔              | 主持人可以管理与会人在会议过程中发送音、视频和实时消息的权限，例如全体静音、允许与会人解除静音、关闭与会人视频等，或邀请某位与会人成为主持人。 |
| 邀请       | ✔    | ✔              | 一键获取会议名称、密码以及会议链接，邀请他人参与会议。       |


### 平台兼容

Agora Meeting 示例项目支持以下平台和版本：

- iOS 10 及以上。iOS 9 系列版本未经验证。
- Android 4.4 及以上。
- Web Chrome 72 及以上，Web 其他浏览器未经验证。

## 快速开始

### 前提条件

在编译及运行 Agora Meeting 示例项目之前，你需要完成以下准备工作。

#### 获取声网 App ID
通过以下步骤获取声网 App ID：
  1. 在声网[控制台](https://sso.agora.io/v2/signup)创建一个账号。
  2. 登录声网控制台，创建一个项目，鉴权方式选择 **“App ID + App 证书 + Token”**。注意，请确保该项目启用了 [App 证书](https://docs.agora.io/cn/Agora%20Platform/token?platform=All%20Platforms#appcertificate)。
  3. 前往**项目管理**页面，获取该项目的 App ID。

#### 进行 HTTP 基本认证

在使用 RESTful API 时，你需要使用声网提供的 Customer ID 和 Customer Certificate 通过 Base64 算法编码生成一个 Authorization 字段，填入 HTTP 请求头部，进行 HTTP 基本认证。详见[具体步骤](https://docs.agora.io/cn/faq/restful_authentication)。

#### 获取第三方白板 sdkToken 并注册到Agora会议云服务
通过以下步骤获取第三方白板 `sdkToken`：
1. 在 [Netless 控制台](https://console.herewhite.com/en/register/)创建一个账号。
2. 登录 Netless 控制台，前往**密钥管理**页面，获取 `sdkToken`。

你需要将白板的 `sdkToken` 注册到Agora会议云服务器中。
1. 打开[Agora控制台](https://Console.Agora.io/)
2. 编辑**项目管理**，移动功能模块，找到白板token，点击“更新token”进行注册。

### 运行示例项目

参考以下文档在对应的平台编译及运行示例项目：

- [Android 运行指南](https://github.com/AgoraIO-Usecase/AgoraMeeting/blob/master/AgoraMeeting_Android/README.zh.md)
- [iOS 运行指南](https://github.com/AgoraIO-Usecase/AgoraMeeting/tree/master/AgoraMeeting_iOS/README.zh.md)
- [Web 运行指南](https://github.com/AgoraIO-Usecase/AgoraMeeting/tree/master/AgoraMeeting_web/README.zh.md)

### 接入 Agora 会议云服务

Agora 会议云服务是声网为后端开发能力稍弱的开发者提供的会议后台管理服务。接入后，你无需自研会议后台业务，通过调用 RESTful API 就能轻松快速实现会议状态管理、权限控制等功能。详见 [Agora 会议云服务文档](https://github.com/AgoraIO-Usecase/AgoraMeeting/wiki/Agora-%E4%BC%9A%E8%AE%AE%E4%BA%91%E6%9C%8D%E5%8A%A1)。

## 常见问题

详见[常见问题](https://github.com/AgoraIO-Usecase/AgoraMeeting/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)。