﻿

USING System.Collections.Generic
USING System.Diagnostics
USING System
USING System.Linq
USING System.IO
USING LanguageService.CodeAnalysis.XSharp

BEGIN NAMESPACE XSharpModel
   
	[DebuggerDisplay("{FullName,nq}")];
	CLASS XAssembly
      PROPERTY Id                   AS Int64 AUTO GET INTERNAL SET
      PROPERTY TypeList             AS XSortedDictionary<STRING, XTypeReference> AUTO
      PROPERTY ExtensionMethods     AS IList<XMemberReference> AUTO
      PROPERTY ImplicitNamespaces   AS IList<String> AUTO
      PROPERTY Namespaces           AS IList<String> AUTO
      PROPERTY ReferencedAssemblies AS IList<String> AUTO
      PROPERTY CustomAttributes     AS IList<String> AUTO
      PROPERTY GlobalClassName      AS STRING AUTO
      PROPERTY FullName             AS STRING AUTO
      PROPERTY RuntimeVersion       AS STRING AUTO
      PROPERTY FileName             AS STRING AUTO
      PROPERTY IsXSharp             AS LOGIC AUTO
      PROPERTY Loaded               AS LOGIC AUTO
      PROPERTY LastChanged          AS DateTime AUTO GET INTERNAL SET
      PROPERTY Size                 AS Int64 AUTO GET INTERNAL SET
      CONSTRUCTOR (cFileName as STRING)
         Id                   := -1
         FileName             := cFileName
         TypeList             := XSortedDictionary<STRING, XTypeReference>{TypeNameComparer{}}
         ImplicitNamespaces   := List<STRING>{}
         Namespaces           := List<STRING>{}
         ReferencedAssemblies := List<STRING>{}
         CustomAttributes     := List<STRING>{}
         GlobalClassName      := ""
         ExtensionMethods     := List<XMemberReference>{}
         LastChanged          := DateTime.MinValue
         Size                 := 0
 
   METHOD Read() AS LOGIC
      var reader := AssemblyReader{FileName}
      reader:Read(SELF)
      XDatabase:Read(SELF)
      var fi := FileInfo{FileName}
      if SELF:Size != fi:Length .or. SELF:LastChanged != fi:LastWriteTime
         XDatabase.Update(SELF)
      ENDIF
      
      RETURN SELF:Loaded

    PRIVATE CLASS TypeNameComparer IMPLEMENTS IComparer<STRING>
      METHOD Compare(x as String, y as String) AS LONG
         if x == NULL .or. y == NULL
            return 0
         endif
         return String.Compare(x, 0, y, 0, y:Length, TRUE)
   END CLASS

   END CLASS
END NAMESPACE   