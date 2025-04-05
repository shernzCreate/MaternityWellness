/**
 * Utility functions to interact with native iOS app features when running in the WebView.
 * These functions will no-op when running in a regular browser.
 */

// Check if we're running inside the iOS app WebView
export const isInNativeApp = (): boolean => {
  return typeof window !== 'undefined' && !!(window as any).isNativeApp;
};

export const isInIOSApp = (): boolean => {
  return typeof window !== 'undefined' && !!(window as any).isiOSApp;
};

// Generic function to send a message to the native app
const sendToNative = (action: string, data: Record<string, any> = {}): void => {
  if (isInIOSApp() && (window as any).webkit?.messageHandlers?.nativeBridge) {
    (window as any).webkit.messageHandlers.nativeBridge.postMessage({
      action,
      ...data,
    });
  } else {
    console.log('Native action would have been triggered:', action, data);
  }
};

// Show a native notification/alert
export const showNativeNotification = (title: string, body: string): void => {
  sendToNative('notification', { title, body });
};

// Open the native share sheet
export const shareContent = (content: string): void => {
  sendToNative('share', { content });
};

// Open the app settings
export const openAppSettings = (): void => {
  sendToNative('openSettings');
};

// Example of a platform detection helper
export const getPlatformName = (): string => {
  if (isInIOSApp()) return 'iOS Native';
  if (isInNativeApp()) return 'Native App';
  return 'Web Browser';
};

/**
 * Helper for conditional rendering based on platform
 * Use like: if (shouldRenderForPlatform(['iOS'])) { ... }
 */
export const shouldRenderForPlatform = (platforms: ('web' | 'iOS' | 'native')[]): boolean => {
  if (platforms.includes('web') && !isInNativeApp()) return true;
  if (platforms.includes('iOS') && isInIOSApp()) return true;
  if (platforms.includes('native') && isInNativeApp()) return true;
  return false;
};