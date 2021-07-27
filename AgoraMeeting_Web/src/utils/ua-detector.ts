import UAParser from "ua-parser-js";

const parser = new UAParser();

const userAgentInfo = parser.getResult();

export const isSafari = () => {
  return (
    userAgentInfo.browser.name === 'Safari' ||
    userAgentInfo.browser.name === 'Mobile Safari'
  );
};

export const isChrome = () => {
  return userAgentInfo.browser.name === 'Chrome';
};

export const isFirefox = () => {
  return userAgentInfo.browser.name === 'Firefox';
};

export const isMobile = () => {
  return userAgentInfo.device.type === 'mobile';
};