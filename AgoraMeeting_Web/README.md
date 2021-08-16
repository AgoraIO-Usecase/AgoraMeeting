> *其他语言版本: [中文](./README.zh.md)*

# This project is no longer maintained, please check for the latest：
```
iOS: https://github.com/AgoraIO-Usecase/AgoraMeeting-iOS
Android: https://github.com/AgoraIO-Usecase/AgoraMeeting-Android
Web: https://github.com/AgoraIO-Usecase/AgoraMeeting-Desktop
```

### Online preview

[web demo](https://solutions.agora.io/meeting/web/)

### Core SDKs
- agora-rtc-sdk (agora rtc web sdk)
- agora-rtm-sdk (agora rtm web sdk)
- white-web-sdk (netless web sdk)

### Frontend tech utilities
- typescript ^3.9.2
- react & react hooks & rxjs
- material-ui
- agora meeting backend service

## Preparations

- Rename `.env.example` to `.env.local` and configure the following parameters:
  - **(Required) Agora App ID, Prefix, Restful Token, Your Board Api** 
  ```bash
  # Agora App ID
   REACT_APP_AGORA_APP_ID=agora_app_id
   REACT_APP_AGORA_EDU_ENDPOINT_PREFIX=https://api.agora.io/scenario/meeting
   REACT_APP_YOUR_BACKEND_WHITEBOARD_API=https://api.agora.io/scenario/meeting/apps/%app_id%/v1/room/%room_id%/board
   REACT_APP_AGORA_RESTFULL_TOKEN=agora_restfull_api_token
  ```  

- Install Node.js LTS

## Run the Web demo
1. Install npm
   ```
   npm install
   ```

2. Locally run the Web demo
   ```
   npm run dev
   ```
3. Release the Web demo. Before the release, you need to change the `"homepage": "Your domain/address"` in `package.json`. For example, you need to change `https://solutions.agora.io/meeting/web` to `"homepage": "https://solutions.agora.io/meeting/web"`
   ```
   npm run build
   ```  
