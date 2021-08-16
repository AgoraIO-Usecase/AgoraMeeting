> *Read this in another language: [English](./README.md)*

# 本项目已经不再维护。最新请到以下地址查看：
```
iOS: https://github.com/AgoraIO-Usecase/AgoraMeeting-iOS
Android: https://github.com/AgoraIO-Usecase/AgoraMeeting-Android
Web: https://github.com/AgoraIO-Usecase/AgoraMeeting-Desktop
```

### 在线体验

[web demo](https://solutions.agora.io/meeting/web/)

### 使用的 SDK

- agora-rtc-sdk（声网 RTC Web SDK）
- agora-rtm-sdk（声网实时消息 Web SDK）
- white-web-sdk（Netless 官方白板 sdk）

### 使用的技术
- typescript ^3.9.2
- react & react hooks & rxjs
- material-ui
- 声望云会议后端服务

## 准备工作

- 重命名 `.env.example` 为 `.env.local`，并配置以下参数：
   - **（必填）声网 App ID**
   ```bash
  # 声望 App ID
   REACT_APP_AGORA_APP_ID=agora_app_id
   REACT_APP_AGORA_EDU_ENDPOINT_PREFIX=https://api.agora.io/scenario/meeting
   REACT_APP_YOUR_BACKEND_WHITEBOARD_API=https://api.agora.io/scenario/meeting/apps/%app_id%/v1/room/%room_id%/board
   REACT_APP_AGORA_RESTFULL_TOKEN=agora_restfull_api_token
   ```  

- 安装 Node.js LTS

## 运行和发布 Web demo

1. 安装 npm

   ```
   npm install
   ```

2. 本地运行 Web demo

   ```
   npm run dev
   ```
3. 发布 Web demo。发布前需要修改 `package.json` 中的 "homepage": "你的域名/地址"。例如，`https://solutions.agora.io/meeting/web` 需修改为 `"homepage": "https://solutions.agora.io/meeting/web"` 

   ```
   npm run build
   ```  
