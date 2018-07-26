import { NativeModules, Platform, processColor } from 'react-native'

const { RNZenDeskSupport } = NativeModules

RNZenDeskSupport.setupTheme = (opts) => {
  if (Platform.OS === "ios") {
    Object.keys(opts).forEach(k => {
      if (k.endsWith("Color")) {
        opts[k] = processColor(opts[k])
      }
    })
    RNZenDeskSupport.applyTheme(opts)
  }
}

export default RNZenDeskSupport || {}
