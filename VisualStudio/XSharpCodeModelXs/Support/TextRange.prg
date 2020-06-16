//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING LanguageService.SyntaxTree
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING System.Threading.Tasks
USING System.Diagnostics
USING System
USING System.Runtime.InteropServices
USING System
BEGIN NAMESPACE XSharpModel
   /// <summary>
   /// 1 based TextRange
   /// </summary>
   [DebuggerDisplay("{DebuggerDisplay(),nq}")];
   STRUCTURE TextRange
      // 0 based line numbers and columns
      INITONLY PRIVATE _EndColumn AS LONG       
      INITONLY PRIVATE _EndLine AS LONG
      INITONLY PRIVATE _StartColumn AS LONG
      INITONLY PRIVATE _StartLine AS LONG
      
      // Methods
      CONSTRUCTOR(context AS ParserRuleContext)
      SELF(context:Start:Line, context:Start:Column, context:Stop:Line, context:Stop:Column)
      //
      
      CONSTRUCTOR(startToken AS IToken, endToken AS IToken)
         SELF:_StartLine     := startToken:Line -1
         SELF:_StartColumn   := startToken:Column -1
         SELF:_EndLine       := endToken:Line -1
         SELF:_EndColumn     := endToken:Column+endToken:Text:Length -1
         
      CONSTRUCTOR(sl AS LONG, sc AS LONG, el AS LONG, ec AS LONG)
         //
         SELF:_StartLine := sl
         SELF:_StartColumn := sc
         SELF:_EndLine := el
         SELF:_EndColumn := ec
         
      METHOD WithEnd(endToken AS IToken) AS TextRange
         RETURN TextRange{_StartLine,_StartColumn,endToken:Line-1,endToken:Column+endToken:Text:Length}
         
         
      STATIC PROPERTY Empty AS TextRange GET TextRange{0, 0, 0, 0}
      
      /// <summary>
      /// 1 based Start Line
      /// </summary>
      PROPERTY StartLine AS LONG GET SELF:_StartLine
      /// <summary>
      /// 1 based End Line
      /// </summary>
      PROPERTY EndLine AS LONG GET SELF:_EndLine
      /// <summary>
      /// 1 based Start Column
      /// </summary>
      PROPERTY StartColumn AS LONG GET SELF:_StartColumn
      /// <summary>
      /// 1 based End Column
      /// </summary>
      PROPERTY EndColumn AS LONG GET SELF:_EndColumn
      
      
      METHOD ContainsExclusive(line AS LONG, col AS LONG) AS LOGIC
         IF ((line > SELF:_StartLine) .AND. (line < SELF:_EndLine))
            RETURN TRUE
         ENDIF
         IF (line == SELF:_StartLine)
            IF (col > SELF:_StartColumn)
               IF (line < SELF:_EndLine)
                  RETURN TRUE
               ENDIF
               IF (line == SELF:_EndLine)
                  RETURN (col < SELF:_EndColumn)
               ENDIF
            ENDIF
            RETURN FALSE
         ENDIF
         RETURN ((line == SELF:_EndLine) .AND. (col < SELF:_EndColumn))
         
      METHOD ContainsInclusive(line AS LONG, col AS LONG) AS LOGIC
         IF ((line > SELF:_StartLine) .AND. (line < SELF:_EndLine))
            RETURN TRUE
         ENDIF
         IF (line == SELF:_StartLine)
            IF (col >= SELF:_StartColumn)
               //
               IF (line < SELF:_EndLine)
                  RETURN TRUE
               ENDIF
               IF (line == SELF:_EndLine)
                  RETURN (col <= SELF:_EndColumn)
               ENDIF
            ENDIF
            RETURN FALSE
         ENDIF
         RETURN ((line == SELF:_EndLine) .AND. (col <= SELF:_EndColumn))
         
      METHOD DebuggerDisplay() AS STRING
         RETURN ToString()
         
         OVERRIDE METHOD ToString() AS STRING
         RETURN i"{StartLine}.{StartColumn}-{EndLine}.{EndColumn}"
   
   END STRUCTURE

END NAMESPACE 
