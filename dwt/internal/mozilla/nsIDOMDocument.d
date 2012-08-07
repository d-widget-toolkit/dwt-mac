module dwt.internal.mozilla.nsIDOMDocument;

import dwt.internal.mozilla.Common;
import dwt.internal.mozilla.nsID;
import dwt.internal.mozilla.nsIDOMNode;
import dwt.internal.mozilla.nsStringAPI;

import dwt.internal.mozilla.nsIDOMNode;
import dwt.internal.mozilla.nsIDOMNodeList;
import dwt.internal.mozilla.nsIDOMDocumentType;
import dwt.internal.mozilla.nsIDOMElement;
import dwt.internal.mozilla.nsIDOMDocumentFragment;
import dwt.internal.mozilla.nsIDOMText;
import dwt.internal.mozilla.nsIDOMComment;
import dwt.internal.mozilla.nsIDOMCDATASection;
import dwt.internal.mozilla.nsIDOMProcessingInstruction;
import dwt.internal.mozilla.nsIDOMDOMImplementation;
import dwt.internal.mozilla.nsIDOMAttr;
import dwt.internal.mozilla.nsIDOMEntityReference;

const char[] NS_IDOMDOCUMENT_IID_STR = "a6cf9075-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMDOCUMENT_IID= 
  {0xa6cf9075, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMDocument : nsIDOMNode {

  static const char[] IID_STR = NS_IDOMDOCUMENT_IID_STR;
  static const nsIID IID = NS_IDOMDOCUMENT_IID;

extern(System):
  nsresult GetDoctype(nsIDOMDocumentType  *aDoctype);
  nsresult GetImplementation(nsIDOMDOMImplementation  *aImplementation);
  nsresult GetDocumentElement(nsIDOMElement  *aDocumentElement);
  nsresult CreateElement(nsAString * tagName, nsIDOMElement *_retval);
  nsresult CreateDocumentFragment(nsIDOMDocumentFragment *_retval);
  nsresult CreateTextNode(nsAString * data, nsIDOMText *_retval);
  nsresult CreateComment(nsAString * data, nsIDOMComment *_retval);
  nsresult CreateCDATASection(nsAString * data, nsIDOMCDATASection *_retval);
  nsresult CreateProcessingInstruction(nsAString * target, nsAString * data, nsIDOMProcessingInstruction *_retval);
  nsresult CreateAttribute(nsAString * name, nsIDOMAttr *_retval);
  nsresult CreateEntityReference(nsAString * name, nsIDOMEntityReference *_retval);
  nsresult GetElementsByTagName(nsAString * tagname, nsIDOMNodeList *_retval);
  nsresult ImportNode(nsIDOMNode importedNode, PRBool deep, nsIDOMNode *_retval);
  nsresult CreateElementNS(nsAString * namespaceURI, nsAString * qualifiedName, nsIDOMElement *_retval);
  nsresult CreateAttributeNS(nsAString * namespaceURI, nsAString * qualifiedName, nsIDOMAttr *_retval);
  nsresult GetElementsByTagNameNS(nsAString * namespaceURI, nsAString * localName, nsIDOMNodeList *_retval);
  nsresult GetElementById(nsAString * elementId, nsIDOMElement *_retval);

}

