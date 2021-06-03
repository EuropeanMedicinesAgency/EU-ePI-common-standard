<!-- XSLT to display an ePI/QRD/SmPC bundle/composition as HTML - Rik 2021-03-12 -->
<!-- it relies on having xhtml text in the input file, and the main task is to turn that into plain html
     (with a few changes such as changing composition.title into another html heading.
	 it will also do some id based lookups, e.g. to put referenced images into the text
-->
	
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:f="http://hl7.org/fhir"
	xmlns:fn="dummy_function_namespace"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="f xhtml fn"
>

<xsl:output omit-xml-declaration="yes" method="html" indent="yes" />
<xsl:strip-space elements="*"/>

<xsl:template match="/">
	<html>
		<xsl:apply-templates/>
		<xsl:call-template name="emitInlineStylesheet"/>
	</html>
</xsl:template>

<!-- bundles that contain bundles -->
<xsl:template match="f:Bundle[f:entry/f:resource/f:Bundle]">
	<xsl:for-each select="f:entry/f:resource/f:Bundle">
		<br/>		
		<xsl:apply-templates select="."/>
		<xsl:if test="position()!=last()"><br/><hr/></xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- Ordinary (document) bundles that don't contain other Bundles -->
<xsl:template match="f:Bundle[not(f:entry/f:resource/f:Bundle)]">
	<xsl:apply-templates select="f:entry/f:resource/f:Composition"/>
</xsl:template>

<xsl:variable name="section-types" select="'http://spor.ema.europa.eu/v1/example-sections'"/>
<xsl:variable name="header-code" select="'header'"/>

<xsl:template match="f:Composition">
	<head>
		<div class="header">
			<xsl:value-of select="f:section[f:code/f:coding[f:system/@value=$section-types]
											[f:code/@value=$header-code]]/f:text/xhtml:div/text()"/>
		</div>
		<xsl:for-each select="f:title">
			<title><xsl:value-of select="@value"/></title>
			<h1 style="text-align:center"><xsl:value-of select="@value"/></h1>
		</xsl:for-each>
	</head>
	<body>
		<div class="divBody">
			<xsl:for-each select="f:section[f:code/f:coding[f:system/@value=$section-types][not(f:code/@value=$header-code)]]">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</div>
	</body>

</xsl:template>

<xsl:template match="f:section">
	<xsl:variable name="level" select="if(ancestor::f:section) then 'h3' else 'h2'"/>
	<xsl:for-each select="f:title">
		<xsl:element name="{$level}">
			<xsl:value-of select="@value"/>
		</xsl:element>
	</xsl:for-each>
	<xsl:apply-templates select="f:text/xhtml:div/(*|text())"/>
	<xsl:apply-templates select="f:section"/>
</xsl:template>

<!-- move things out of the xhtml namespace, so they can be styled as plain html -->
<xsl:template match="xhtml:*">
	<xsl:element name="{local-name(.)}">
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="xhtml:img">
	<img>
		<xsl:copy-of select="@*[not(local-name()='src')]"/>
		<xsl:variable name="src" select="replace(@src,'#','')"/>
		<xsl:for-each select="//f:Binary[f:id/@value=$src]">
			<xsl:attribute name="src" select="concat('data:',f:contentType/@value,';base64, ',f:data/@value)"/>
		</xsl:for-each>
	</img>
</xsl:template>

<xsl:template match="*" mode="catchall">
	<span>[skipping item <xsl:value-of select="concat(local-name(..),'.',local-name(.))"/>]</span>
</xsl:template>

<xsl:function name="fn:convertYYYY-MM-DDtoDD-MMM-YYYY">
	<xsl:param name="s"/>
	<xsl:variable name="year" select="substring($s,1,4)"/>
	<xsl:variable name="month" select="substring($s,6,2)"/>
	<xsl:variable name="day" select="substring($s,9,2)"/>
	<xsl:variable name="monthText">
		<xsl:choose>
			<xsl:when test="$month='01'">January</xsl:when>
			<xsl:when test="$month='02'">February</xsl:when>
			<xsl:when test="$month='03'">March</xsl:when>
			<xsl:when test="$month='04'">April</xsl:when>
			<xsl:when test="$month='05'">May</xsl:when>
			<xsl:when test="$month='06'">June</xsl:when>
			<xsl:when test="$month='07'">July</xsl:when>
			<xsl:when test="$month='08'">August</xsl:when>
			<xsl:when test="$month='09'">September</xsl:when>
			<xsl:when test="$month='10'">October</xsl:when>
			<xsl:when test="$month='11'">November</xsl:when>
			<xsl:when test="$month='12'">December</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="concat($day,' ',$monthText,' ',$year)"/>
</xsl:function>

<!-- CSS, done inline to help distributing the HMTL file -->
<xsl:template name="emitInlineStylesheet">
	<style>

@media all {
    .header { font-size:12pt; font-weight:bold; text-align:center; margin-bottom:0px; }
    body { font:10pt 'Verdana'; margin-right:1.5em; }
    h1 { font-size:16pt; text-weight:bold; }
    h2 { font-size:12pt; margin-top:20px; color:blue; }
    h3 { font-size:12pt; font-weight:bold; }
    p { margin:0; padding:0; }
    table,tr,td,th { border: 1px solid black; font-size:10pt;}

    .ecl-u-mv-m, ecl-editor, ecl-table { font-family: Verdana,sans-serif; }
    .ecl-table { border-collapse: collapse; }
    .odd { background-color: lightgrey; }
    .ecl-table {
    	border-collapse: collapse;
	    border-width: 0;
    	font-size: 10pt;
    	margin: 0;
    	table-layout: fixed;
    	width: 100%
	}
	.ecl-table th {
	    background-color: transparent;
	    color: #404040;
	    font-weight: 700;
	    text-align: left
	}
	.ecl-table td, .ecl-table th {
    	display: table-cell;
    	padding: .89rem;
    	vertical-align: middle
	}
    .ecl-table thead tr:first-child th {
    	border-bottom: none;
   	 	background-color: rgb(0, 51, 153);
   	 	vertical-align: top;
    	color: #fff;
	}
}
	</style>
</xsl:template>

</xsl:stylesheet>