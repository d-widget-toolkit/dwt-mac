module dwt.internal.mozilla.nsIEmbeddingSiteWindow2;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsIEmbeddingSiteWindow;

const char[] NS_IEMBEDDINGSITEWINDOW2_IID_STR = "e932bf55-0a64-4beb-923a-1f32d3661044";

const nsIID NS_IEMBEDDINGSITEWINDOW2_IID= 
  {0xe932bf55, 0x0a64, 0x4beb, 
    [ 0x92, 0x3a, 0x1f, 0x32, 0xd3, 0x66, 0x10, 0x44 ]};

interface nsIEmbeddingSiteWindow2 : nsIEmbeddingSiteWindow {

  static const char[] IID_STR = NS_IEMBEDDINGSITEWINDOW2_IID_STR;
  static const nsIID IID = NS_IEMBEDDINGSITEWINDOW2_IID;

extern(System):
  nsresult Blur();

}

