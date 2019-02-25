//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System
USING System.Collections
USING System.Collections.Generic
USING System.Text
USING System.IO
USING System.Runtime.CompilerServices
USING System.Diagnostics

BEGIN NAMESPACE XSharp.RDD.CDX

	/// <summary>
	/// The CdxTagList class is a special CdxLeaf. Its NodeAttribute must be Root + Leaf = TagList
	/// </summary>
	INTERNAL CLASS CdxTagList INHERIT CdxLeafPage
        PROTECTED _tags AS List<CdxTag>

	    PROTECTED INTERNAL CONSTRUCTOR( bag AS CdxOrderBag , page AS CdxPage)
            SUPER(bag  , page)

        INTERNAL METHOD ReadTags() AS List<CdxTag>
            _tags := List<CdxTag>{}
            Debug.Assert (SELF:PageType:HasFlag(CdxPageType.TagList))
            FOR VAR nI := 0 TO SELF:NumKeys-1
                LOCAL nRecno    := SELF:GetRecno(nI) AS Int32
                LOCAL bName     := SELF:GetKey(nI)  AS BYTE[]
                LOCAL cName     := System.Text.Encoding.ASCII:GetString( bName, 0, bName:Length) AS STRING
                VAR tag         := CdxTag{_bag,  nRecno, cName:Trim()}
                _tags:Add(tag)
            NEXT
            // default sort for tags in an orderbag is on pageno. 
            _tags:Sort( { tagX, tagY => tagX:Page - tagY:Page} ) 
            RETURN _tags
        PROPERTY Tags AS IList<cdxTag> GET _tags

        INTERNAL OVERRIDE METHOD Initialize(keyLength AS WORD) AS VOID
            SUPER:Initialize(keyLength)
            _tags := List<CdxTag>{}
            SELF:PageType := CdxPageType.TagList


        METHOD Add(oTag AS CdxTag) AS LOGIC
            SELF:NumKeys += 1
            SELF:SetRecno (SELF:NumKeys-1, oTag:header:PageNo)
            VAR buffer := BYTE[]{oTag:OrderName:Length}
            _SetString(buffer, 0, buffer:Length, oTag:OrderName)
            SELF:SetKey(SELF:NumKeys-1, buffer)
            SELF:Write()
            RETURN TRUE
    END CLASS
END NAMESPACE 