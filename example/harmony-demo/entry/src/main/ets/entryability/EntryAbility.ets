import { RNAbility } from '@rnoh/react-native-openharmony';
import { Want } from '@kit.AbilityKit';
import hilog from '@ohos.hilog';

export default class EntryAbility extends RNAbility {
  getPagePath() {
    return 'pages/Index';
  }

  override onCreate(want: Want): void {
    super.onCreate(want);
    hilog.info(0x0000, 'testTag', '%{public}s', 'EntryAbility onCreate');
  }
}