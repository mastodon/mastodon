<?xml version="1.0" encoding="UTF-8"?>
<schema 
  targetNamespace="urn:oasis:names:tc:SAML:metadata:algsupport"
  xmlns="http://www.w3.org/2001/XMLSchema"
  xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
  elementFormDefault="unqualified"
  attributeFormDefault="unqualified"
  blockDefault="substitution"
  version="1.0">

  <annotation>
    <documentation>
      Document title: Metadata Extension Schema for SAML V2.0 Metadata Profile for Algorithm Support Version 1.0
      Document identifier: sstc-saml-metadata-algsupport.xsd
      Location: http://docs.oasis-open.org/security/saml/Post2.0/
      Revision history:
      V1.0 (June 2010):
        Initial version.
    </documentation>
  </annotation>

  <element name="DigestMethod" type="alg:DigestMethodType"/>
  <complexType name="DigestMethodType">
    <sequence>
      <any namespace="##any" processContents="lax" minOccurs="0" maxOccurs="unbounded"/>
    </sequence>
    <attribute name="Algorithm" type="anyURI" use="required"/>
  </complexType>

  <element name="SigningMethod" type="alg:SigningMethodType"/>
  <complexType name="SigningMethodType">
    <sequence>
      <any namespace="##any" processContents="lax" minOccurs="0" maxOccurs="unbounded"/>
    </sequence>
    <attribute name="Algorithm" type="anyURI" use="required"/>
    <attribute name="MinKeySize" type="positiveInteger"/>
    <attribute name="MaxKeySize" type="positiveInteger"/>
  </complexType>

</schema>

