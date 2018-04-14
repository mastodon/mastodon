# MIME Types Changes by Version

## 3.2016.0521 / 2016-05-21

*   Updated the known extension list for application/octet-stream and
    application/pgp-encrypted to include gpg as an extension. Fixes
    [#3](https://github.com/mime-types/mime-types-data/pull/3) by Tao Guo
    (@taoza).
*   Updated the IANA media registry entries as of release date:

    *   Updated metadata for application/EmergencyCallData.Comment\+xml,
        application/EmergencyCallData.DeviceInfo\+xml,
        application/EmergencyCallData.ProviderInfo\+xml,
        application/EmergencyCallData.ServiceInfo\+xml,
        application/EmergencyCallData.SubscriberInfo\+xml,
        application/ogg, application/problem\+json, application/problem\+xml,
        audio/ogg, text/markdown, video/H265, video/ogg.
    *   Added application/efi, application/vnd.3gpp.sms\+xml,
        application/vnd.3lightssoftware.imagescal,
        application/vnd.coreos.ignition\+json, application/vnd.oma.lwm2m\+json,
        application/vnd.onepager, application/vnd.quarantainenet,
        application/vnd.vel\+json, image/emf, image/wmf, text/prs.prop.logic.
    *   image/bmp has a draft RFC which would make it official; it has been
        finally been registered. As such, this version *reverses* the
        use-instead relationship of image/bmp and image/x-bmp.

*   This version requires mime-types 3.1 or later to manage data because of an
    issue with JSON data encoding for the `xrefs` field.

## 3.2016.0221 / 2016-02-21

*   Updated the known extensions list for audio/mp4.
*   Updated the IANA media registry entries as of release date:

    *   Updated metadata for 3GPP-defined types (there are many),
        application/cdni, and application/rfc+xml.
    *   Added application/EmergencyCallData.Comment+xml,
        application/EmergencyCallData.DeviceInfo+xml,
        application/EmergencyCallData.ProviderInfo+xml,
        application/EmergencyCallData.ServiceInfo+xml,
        application/ppsp-tracker+json, application/problem+json,
        application/problem+xml, application/vnd.filmit.zfc,
        application/vnd.hdt, application/vnd.mapbox-vector-tile,
        application/vnd.ms-PrintDeviceCapabilities+xml,
        application/vnd.ms-PrintSchemaTicket+xml,
        application/vnd.ms-windows.nwprinting.oob, application/vnd.tml,
        model/vnd.rosette.annotated-data-model, and video/H265.

*   Updated to [Contributor Covenant 1.4][Code of Conduct].
*   Shift the support code in this repository to be developed with Ruby 2.3.
    This involves:

    *   Adding `frozen_string_literal: true` to all Ruby files.
    *   Applied some recommended readability and performance suggestions from
        Rubocop. Ignored some style recommendations, too.
    *   Replaced some cases of `foo.bar rescue nil` with `foo&.bar`.

## 3.2015.1120 / 2015-11-20

*   Extracted from [ruby-mime-types][rmt].
*   Added a [Code of Conduct][].
*   The versioning has changed to be semantic on format plus date in two parts.

    *   All registry formats have been updated to remove deprecated data.
    *   The columnar format has been updated to store three boolean flags in a
        single flags file.

*   Updated the conversion and management utilities to work with
    ruby-mime-types 3.x.

*   Updated the IANA media registry entries as of release date:

    *  Updated metadata for application/scim+json, audio/G711-0, text/markdown. 

    *  Added application/cdni, application/csvm+json, application/rfc+xml,
       application/vnd.3gpp.access-transfer-events+xml,
       application/vnd.3gpp.srvcc-ext+xml, application/vnd.3gpp.SRVCC-info+xml,
       application/vnd.ms-windows.devicepairing,
       application/vnd.ms-windows.wsd.oob, application/vnd.oxli.countgraph,
       application/vnd.pagerduty+json, video/VP8.

## 2.6.2 / 2015-09-13

*   Updated the IANA media registry entries as of release date:

    *   Updated metadata for application/cals-1840, application/index.obj,
        application/ocsp-response, application/vnd.dtg.local.html,
        application/vnd.pwg-multiplexed, audio/G7221, audio/opus.

    *   Added application/pkcs12, application/scim+json, multipart/form-data.
        application/vnd.3gpp-prose+xml, application/vnd.3gpp-prose-pc3ch+xml,
        application/vnd.3gpp.mid-call+xml,
        application/vnd.3gpp-state-and-event-info+xml,
        application.3gpp.ussd+xml, application/vnd.anki,
        application/vnd.biopax.rdf+xml, application/vnd.drive+json,
        application/vnd.firemonkeys.cloudcell,
        application/vnd.hyperdrive+json, application/vnd.openblox.game+xml,
        application/vnd.openblox.game-binary, application/vnd.uri-map,
        audio/G711-0, image/vnd.mozilla.apng.

## 2.6 / 2015-05-25

*   Steven Michael Thomas (@stevenmichaelthomas) added `woff2` as an extension
    to application/font-woff,
    [ruby-mime-types#99](https://github.com/mime-types/ruby-mime-types/pull/99).
*   Updated the IANA media registry entries as of release date:
    *   Updated metadata for application/jose, application/jose+json,
        application/jwk+json, application/jwk-set+json, application/jwt to
        reflect the adoption of RFC7519.
    *   Added application/vnd.balsamiq.bmpr.

## 2.5 / 2015-04-25

*   Updated the IANA media registry entries as of release date:
    *   Added MIME types: application/A2L, application/AML, application/ATFX,
        application/ATXML, application/CDFX+XML, application/CEA,
        application/DII, application/DIT, application/jose,
        application/jose+json, application/json-seq, application/jwk+json,
        application/jwk-set+json, application/jwt, application/LXF,
        application/MF4, application/rdap+json,
        application/vnd.apache.thrift.compact, vnd.apache.thrift.json,
        application/vnd.citationstyles.style+xml, application/vnd.coffeescript,
        application/vnd.enphase.envoy, application/vnd.fastcopy-disk-image,
        application/vnd.gerber, application/vnd.gov.sk.e-form+xml,
        application/vnd.gov.sk.e-form+zip,
        application/vnd.gov.sk.xmldatacontainer+xml,
        application/vnd.ims.imsccv1p1, application/vnd.ims.imsccv1p2,
        application/vnd.ims.imsccv1p3, application/vnd.micro+json,
        application/vnd.microsoft.portable-executable,
        application/vnd.msa-disk-image, application/vnd.oracle.resource+json,
        application/vnd.tmd.mediaflex.api+xml, audio/opus,
        image/vnd.zbrush.pcx, text/csv-schema, text/markdown (marked as
        TEMPORARY).
    *   Updated metadata for application/coap-group+json (RFC7390),
        application/epub+zip (now registered), application/merge-patch+json
        (RFC7396), application/smil, application/vnd.arastra.swi,
        application/vnd.geocube+xml, application/vnd.gmx,
        application/xhtml+xml, text/directory.
*   Andy Brody (@ab) fixed a pair of embarrassing typos in text/csv and
    text/tab-separated-values,
    [ruby-mime-types#89](https://github.com/mime-types/ruby-mime-types/pull/89).
*   Aggelos Avgerinos (@eavgerinos) added the unregistered MIME type
    image/x-ms-bmp with the extension `bmp`,
    [ruby-mime-types#90](https://github.com/mime-types/ruby-mime-types/pull/90).

## 2.4.2 / 2014-10-15

*   Added application/vnd.ms-outlook as an unregistered MIME type with the
    extension `msg`. Provided by @keerthisiv in
    [ruby-mime-types#72](https://github.com/mime-types/ruby-mime-types/pull/72).

## 2.4.1 / 2014-10-07

*   Changed the sort order of many of the extensions to restore behaviour from
    mime-types 1.25.1.
*   Added `friendly` MIME::Type descriptions where known.
*   Added `reg`, `ps1`, and `vbs` extensions to application/x-msdos-program and
    application/x-msdownload.
*   Updated the IANA media registry entries as of release date.
    *   Several MIME types had updated metadata (application/alto-*, RFC7285;
        application/calendar+json, RFC7265; application/http, RFC7230;
        application/xml, RFC7303; application/xml-dtd, RFC7303;
        application/xml-external-parsed-entity, RFC7303; audio/AMR-WB, RFC4867;
        audio/aptx, RFC7310; message/http, RFC7230; multipart/byteranges,
        RFC7233; text/xml, RFC7303; text/xml-external-parsed-entity, RFC7303)
    *   MIME::Type application/EDI-Consent was renamed to
        application/EDI-consent.
    *   Obsoleted application/vnd.informix-visionary in favour of
        application/vnd.visionary. Obsoleted
        application/vnd.nokia.n-gage.symbian.install with no replacement.
    *   Added MIME types: application/ATF, application/coap-group+json,
        application/DCD, application/merge-patch+json, application/scaip+xml,
        application/vnd.apache.thrift.binary, application/vnd.artsquare,
        application/vnd.doremir.scorecloud-binary-document,
        application/vnd.dzr, application/vnd.maxmind.maxmind-db,
        application/vnd.ntt-local.ogw_remote-access, application/xml-patch+xml,
        image/vnd.tencent.tap.

## 2.3 / 2014-05-23

*   Updated the IANA media registry entries as of release date.
    *   Several MIME types had additional metadata added on the most recent
        import.
    *   MIME::Type application/pidfxml was renamed to application/pidf+xml.
    *   Added MIME types: application/3gpdash-qoe-report+xml,
        application/alto-costmap+json, application/alto-costmapfilter+json,
        application/alto-directory+json, application/alto-endpointcost+json,
        application/alto-endpointcostparams+json,
        application/alto-endpointprop+json,
        application/alto-endpointpropparams+json, application/alto-error+json,
        application/alto-networkmap+json,
        application/alto-networkmapfilter+json, application/calendar+json,
        application/vnd.debian.binary-package, application/vnd.geo+json,
        application/vnd.ims.lis.v2.result+json,
        application/vnd.ims.lti.v2.toolconsumerprofile+json,
        application/vnd.ims.lti.v2.toolproxy+json,
        application/vnd.ims.lti.v2.toolproxy.id+json,
        application/vnd.ims.lti.v2.toolsettings+json,
        application/vnd.ims.lti.v2.toolsettings.simple+json,
        application/vnd.mason+json, application/vnd.miele+json,
        application/vnd.ms-3mfdocument, application/vnd.panoply,
        application/vnd.valve.source.material, application/vnd.yaoweme,
        audio/aptx, image/vnd.valve.source.texture, model/vnd.opengex,
        model/vnd.valve.source.compiled-map, model/x3d+fastinfoset,
        text/cache-manifest

## 2.2 / 2014-03-14
*   Added <tt>.sj</tt> to `application/javascript` as provided by Brandon
    Galbraith (@brandongalbraith) in
    [ruby-mime-types#58](https://github.com/mime-types/ruby-mime-types/pull/58).
*   Marked application/excel and application/x-excel as obsolete in favour of
    application/vnd.ms-excel per
    [ruby-mime-types#60](https://github.com/mime-types/ruby-mime-types/pull/60).
*   Merged duplicate MIME types into the registered MIME type. The only
    difference between the MIME types was capitalization; the MIME type
    registry is case-preserving.
    *   Affected MIME types: application/vnd.3M.Post-it-Notes,
        application/vnd.FloGraphIt, application/vnd.HandHeld-Entertainment+xml,
        application/vnd.hp-HPGL, application/vnd.hp-PCL,
        application/vnd.hp-PCLXL, application/vnd.ibm.MiniPay,
        application/vnd.Kinar, application/vnd.MFER,
        application/vnd.Mobius.DAF, application/vnd.Mobius.DIS,
        application/vnd.Mobius.MBK, application/vnd.Mobius.MSL,
        application/vnd.Mobius.MQY, application/vnd.Mobius.PLC,
        application/vnd.Mobius.TXF,
        application/vnd.ms-excel.addin.macroEnabled.12,
        application/vnd.ms-excel.sheet.binary.macroEnabled.12,
        application/vnd.ms-excel.sheet.macroEnabled.12,
        application/vnd.ms-excel.template.macroEnabled.12,
        application/vnd.ms-powerpoint.addin.macroEnabled.12,
        application/vnd.ms-powerpoint.presentation.macroEnabled.12,
        application/vnd.ms-powerpoint.slide.macroEnabled.12,
        application/vnd.ms-powerpoint.slideshow.macroEnabled.12,
        application/vnd.ms-powerpoint.template.macroEnabled.12,
        application/vnd.ms-word.document.macroEnabled.12,
        application/vnd.ms-word.template.macroEnabled.12,
        application/vnd.novadigm.EDM, application/vnd.novadigm.EDX,
        application/vnd.novadigm.EXT, application/vnd.Quark.QuarkXPress,
        application/vnd.SimTech-MindMapper, audio/AMR-WB, video/H261,
        video/H263, video/H264, video/JPEG, video/MJ2.

*   Updated the IANA media registry entries as of release date.
    *   Registered type person names have been updated from surname only to
        full name.
    *   Several types had updated RFC or draft RFC references.
    *   Added application/bacnet-xdd+zip, application/cms,
        application/load-control+xml, application/PDX, application/ttml+xml,
        application/vnd.collection.doc+json,
        application/vnd.iptc.g2.catalogitem+xml, application/vnd.pcos,
        text/parameters, text/vnd.a, video/iso.segment

## 2.1 / 2014-01-25

*   The IANA media type registry format changed, resulting in updates to most
    of the 1,427 registered MIME types.
    *   Many registered MIME types have had some metadata updates due to the
        change in the IANA registry format.
        *   MIME types having a publicly available registry application now
            include a link to that file in references.
    *   Added `xrefs` data as discovered (see the API changes noted above).
*   The Apache mime types configuration has been added to track additional
    common but unregistered MIME types and known extensions for those MIME
    types. This has affected many of the available MIME types.
*   Added newly registered MIME types:
    *   application/emotionml+xml, application/ODX, application/prs.hpub+zip,
        application/vcard+json, application/vnd.bekitzur-stech+json,
        application/vnd.etsi.timestamp-token,
        application/vnd.oma.cab-feature-handler+xml,
        application/vnd.openeye.oeb, application/vnd.tcpdump.pcap,
        audio/amr-wb, model/x3d+xml, model/x3d-vrml
*   Added 180 unregistered MIME types from the Apache list:
    *   application/applixware, application/cu-seeme, application/docbook+xml,
        application/gml+xml, application/gpx+xml, application/gxf,
        application/java-archive, application/java-serialized-object,
        application/java-vm, application/jsonml+json, application/metalink+xml,
        application/omdoc+xml, application/onenote, application/pics-rules,
        application/rsd+xml, application/ssdl+xml,
        application/vnd.3m.post-it-notes, application/vnd.amazon.ebook,
        application/vnd.anser-web-funds-transfer-initiation,
        application/vnd.curl.car, application/vnd.curl.pcurl,
        application/vnd.dolby.mlp, application/vnd.ds-keypoint,
        application/vnd.flographit, application/vnd.handheld-entertainment+xml,
        application/vnd.hp-hpgl, application/vnd.hp-pcl,
        application/vnd.hp-pclxl, application/vnd.ibm.minipay,
        application/vnd.kinar, application/vnd.mfer,
        application/vnd.mobius.daf, application/vnd.mobius.dis,
        application/vnd.mobius.mbk, application/vnd.mobius.mqy,
        application/vnd.mobius.msl, application/vnd.mobius.plc,
        application/vnd.mobius.txf,
        application/vnd.ms-excel.addin.macroenabled.12,
        application/vnd.ms-excel.sheet.binary.macroenabled.12,
        application/vnd.ms-excel.sheet.macroenabled.12,
        application/vnd.ms-excel.template.macroenabled.12,
        application/vnd.ms-pki.seccat, application/vnd.ms-pki.stl,
        application/vnd.ms-powerpoint.addin.macroenabled.12,
        application/vnd.ms-powerpoint.presentation.macroenabled.12,
        application/vnd.ms-powerpoint.slide.macroenabled.12,
        application/vnd.ms-powerpoint.slideshow.macroenabled.12,
        application/vnd.ms-powerpoint.template.macroenabled.12,
        application/vnd.ms-word.document.macroenabled.12,
        application/vnd.ms-word.template.macroenabled.12,
        application/vnd.novadigm.edm, application/vnd.novadigm.edx,
        application/vnd.novadigm.ext, application/vnd.quark.quarkxpress,
        application/vnd.rim.cod, application/vnd.rn-realmedia-vbr,
        application/vnd.simtech-mindmapper, application/vnd.symbian.install,
        application/winhlp, application/x-abiword,
        application/x-ace-compressed, application/x-authorware-bin,
        application/x-authorware-map, application/x-authorware-seg,
        application/x-bittorrent, application/x-blorb, application/x-bzip,
        application/x-cbr, application/x-cfs-compressed, application/x-chat,
        application/x-conference, application/x-dgc-compressed,
        application/x-doom, application/x-dtbncx+xml, application/x-dtbook+xml,
        application/x-dtbresource+xml, application/x-envoy, application/x-eva,
        application/x-font-bdf, application/x-font-ghostscript,
        application/x-font-linux-psf, application/x-font-otf,
        application/x-font-pcf, application/x-font-snf, application/x-font-ttf,
        application/x-font-type1, application/x-freearc,
        application/x-gca-compressed, application/x-glulx,
        application/x-gnumeric, application/x-gramps-xml,
        application/x-install-instructions, application/x-iso9660-image,
        application/x-lzh-compressed, application/x-mie,
        application/x-ms-application, application/x-ms-shortcut,
        application/x-ms-xbap, application/x-msbinder,
        application/x-mscardfile, application/x-msclip,
        application/x-msmediaview, application/x-msmetafile,
        application/x-msmoney, application/x-mspublisher,
        application/x-msschedule, application/x-msterminal,
        application/x-mswrite, application/x-nzb, application/x-pkcs12,
        application/x-pkcs7-certificates, application/x-pkcs7-certreqresp,
        application/x-research-info-systems, application/x-silverlight-app,
        application/x-sql, application/x-stuffitx, application/x-subrip,
        application/x-t3vm-image, application/x-tads, application/x-tex-tfm,
        application/x-tgif, application/x-xfig, application/x-xliff+xml,
        application/x-xz, application/x-zmachine, application/xaml+xml,
        application/xproc+xml, application/xspf+xml, audio/adpcm, audio/amr-wb,
        audio/AMR-WB, audio/midi, audio/s3m, audio/silk, audio/x-caf,
        audio/x-flac, audio/x-matroska, audio/x-mpegurl, audio/xm,
        chemical/x-cdx, chemical/x-cif, chemical/x-cmdf, chemical/x-cml,
        chemical/x-csml, image/sgi, image/vnd.ms-photo, image/x-3ds,
        image/x-cmx, image/x-freehand, image/x-icon, image/x-mrsid-image,
        image/x-pcx, image/x-tga, model/x3d+binary, model/x3d+vrml, text/plain,
        text/vnd.curl.dcurl, text/vnd.curl.mcurl, text/vnd.curl.scurl,
        text/x-asm, text/x-c, text/x-fortran, text/x-java-source, text/x-nfo,
        text/x-opml, text/x-pascal, text/x-sfv, text/x-uuencode, video/h261,
        video/h263, video/h264, video/jpeg, video/jpm, video/mj2, video/x-f4v,
        video/x-m4v, video/x-mng, video/x-ms-vob, video/x-smv
*   Merged the non-standard VMS platform text/plain with the standard
    text/plain.

[rmt]: https://github.com/mime-types/ruby-mime-types
[Code of Conduct]: Code-of-Conduct.md
