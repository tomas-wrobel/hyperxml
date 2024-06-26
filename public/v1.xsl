<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="no" encoding="UTF-8" standalone="no" omit-xml-declaration="yes" />
    <xsl:strip-space elements="*" />

    <!-- Root -->
    <xsl:template match="/">
        <html>
            <xsl:apply-templates select="hyperxml/@*" />
            <xsl:apply-templates select="hyperxml/head" />
            <xsl:apply-templates select="hyperxml/body" />
        </html>
    </xsl:template>

    <!-- 
        HyperXML makes the head easier to work with.

        1. title can be set as an attribute of head, or not set at all.
        2. head is pre-populated with meta tags for charset and viewport.
    -->
    <xsl:template match="head/@title" />
    <xsl:template match="head">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            <xsl:if test="not(meta[@name='viewport'])">
                <meta name="viewport" content="width=device-width, initial-scale=1" />
            </xsl:if>
            <xsl:apply-templates select="meta | link | style | script | base" />
            <title>
                <xsl:choose>
                    <xsl:when test="@title">
                        <xsl:value-of select="@title" />
                    </xsl:when>
                    <xsl:when test="title">
                        <xsl:value-of select="title" />
                    </xsl:when>
                    <xsl:otherwise>
                        <title>Untitled</title>
                    </xsl:otherwise>
                </xsl:choose>
            </title>
        </head>
    </xsl:template>

    <!-- HyperXML adds src attribute to style -->
    <xsl:template match="style">
        <xsl:choose>
            <!-- src="url" is converted to @import url(url); -->
            <xsl:when test="@src and (@type='text/css' or not(@type))">
                <style>
                    <xsl:apply-templates select="@*" />
                    <xsl:text>@import url(</xsl:text>
                    <xsl:value-of select="@src" />
                    <xsl:text>);</xsl:text>
                </style>
            </xsl:when>
            <xsl:otherwise>
                <style>
                    <xsl:apply-templates select="@*" />
                    <xsl:value-of select="." />
                </style>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="style/@src" />

    <!-- Definitions -->
    <xsl:template match="definition" />

    <xsl:template match="include">
        <xsl:variable name="def" select="@definition" />
        <xsl:variable name="id" select="generate-id()" />

        <xsl:for-each select="//definition">
            <xsl:if test="@name = $def">
                <xsl:apply-templates select="node()">
                    <xsl:with-param name="id" select="$id" />
                </xsl:apply-templates>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="parameter">
        <xsl:param name="id" />
        <xsl:variable name="name" select="@name" />

        <xsl:choose>
            <xsl:when test="//include[generate-id() = $id]/parameter[@name = $name]">
                <xsl:apply-templates select="//include[generate-id() = $id]/parameter[@name = $name]/node()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Copy to HTML -->
    <xsl:template match="@*">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="." />
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="node()">
        <xsl:param name="id" />
        <xsl:copy>
            <xsl:apply-templates select="@* | node()">
                <!-- Pass id for include -->
                <xsl:with-param name="id" select="$id" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>