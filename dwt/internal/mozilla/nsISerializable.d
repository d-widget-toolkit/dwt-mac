/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Mozilla Communicator client code, released March 31, 1998.
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by Netscape are Copyright (C) 1998-1999
 * Netscape Communications Corporation.  All Rights Reserved.
 *
 * Contributor(s):
 *
 * IBM
 * -  Binding to permit interfacing between Mozilla and DWT
 * -  Copyright (C) 2003, 2009 IBM Corp.  All Rights Reserved.
 *
 * ***** END LICENSE BLOCK ***** */
module dwt.internal.mozilla.nsISerializable;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsISupports;

import dwt.internal.mozilla.nsIObjectInputStream;
import dwt.internal.mozilla.nsIObjectOutputStream;

const char[] NS_ISERIALIZABLE_IID_STR = "91cca981-c26d-44a8-bebe-d9ed4891503a";

const nsIID NS_ISERIALIZABLE_IID=
  {0x91cca981, 0xc26d, 0x44a8,
    [ 0xbe, 0xbe, 0xd9, 0xed, 0x48, 0x91, 0x50, 0x3a ]};

interface nsISerializable : nsISupports {
        new nsID(NS_ISERIALIZABLE_IID_STR);

  static const char[] IID_STR = NS_ISERIALIZABLE_IID_STR;
  static const nsIID IID = NS_ISERIALIZABLE_IID;
    }

extern(System):
  nsresult Read(nsIObjectInputStream aInputStream);
  nsresult Write(nsIObjectOutputStream aOutputStream);

    public int Write(int /*long*/ aOutputStream) {
        return XPCOM.VtblCall(nsISupports.LAST_METHOD_ID + 2, getAddress(), aOutputStream);
    }
}

