//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
// functions used by the compiler


/// <inheritdoc cref="M:XSharp.RuntimeState.StringCompare(System.String,System.String)" />
FUNCTION __StringCompare(strLHS AS STRING, strRHS AS STRING) AS INT
    RETURN RuntimeState.StringCompare(strLHS, strRHS)

    
    /// <summary>
    /// Compare 2 strings. This function is used by the compiler for string comparisons
    /// </summary>
    /// <param name="strLHS">The first string .</param>
    /// <param name="strRHS">The second string.</param>
    /// <returns>
    /// TRUE when the strings are equal, FALSE when they are not equal
    /// This function respects SetExact()
    /// </returns>
FUNCTION  __StringEquals(strLHS AS STRING, strRHS AS STRING) AS LOGIC
    LOCAL IsEqual:= FALSE AS LOGIC
    LOCAL lengthRHS AS INT
    IF Object.ReferenceEquals(strLHS, strRHS)
        IsEqual := TRUE
    ELSEIF RuntimeState.Exact
        IsEqual := String.Equals(strLHS , strRHS)
    ELSEIF strLHS != NULL .AND. strRHS != NULL
        lengthRHS := strRHS:Length
        IF lengthRHS == 0
            IsEqual := TRUE        // With SetExact(FALSE) then "aaa" = "" returns TRUE
        ELSEIF lengthRHS <= strLHS:Length
        
            IsEqual := String.Compare( strLHS, 0, strRHS, 0, lengthRHS, StringComparison.Ordinal ) == 0
        ENDIF
    ELSEIF strLHS == NULL .AND. strRHS == NULL
        IsEqual := TRUE
    ENDIF
    RETURN IsEqual
    
    /// <summary>
    /// Compare 2 strings. This function is used by the compiler for string comparisons
    /// </summary>
    /// <param name="strLHS">The first string .</param>
    /// <param name="strRHS">The second string.</param>
    /// <returns>
    /// TRUE when the strings are not equal, FALSE when they are equal
    /// This function respects SetExact()
    /// </returns>
FUNCTION  __StringNotEquals(strLHS AS STRING, strRHS AS STRING) AS LOGIC
    LOCAL notEquals := FALSE AS LOGIC
    LOCAL lengthRHS AS INT
    IF Object.ReferenceEquals(strLHS, strRHS)
        notEquals := FALSE
    ELSEIF RuntimeState.Exact
        notEquals := !String.Equals(strLHS , strRHS)
    ELSEIF strLHS != NULL .AND. strRHS != NULL
        // shortcut: chec first char
        lengthRHS := strRHS:Length
        IF lengthRHS == 0
            notEquals := FALSE        // With SetExact(FALSE) then "aaa" = "" returns TRUE
        ELSEIF lengthRHS <= strLHS:Length
            notEquals := String.Compare( strLHS, 0, strRHS, 0, lengthRHS, StringComparison.Ordinal ) != 0
        ELSE
            notEquals := TRUE
        ENDIF
    ELSEIF strLHS == NULL .AND. strRHS == NULL
        notEquals := FALSE
    ELSE
        notEquals := TRUE
    ENDIF
    RETURN notEquals

/// <summary>Assign a value to a field </summary>
/// <param name="area">Workarea in which the expression will be evaluated.</param>
/// <param name="fieldName">FieldName to assign.</param>
/// <param name="uValue">Value to assign.</param>
/// <returns>The value of the field.</returns>
/// <example>
/// FIELD FirstName
/// ? FirstName
/// ? FIELD->LastName
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when a field is accessed.</remarks>
FUNCTION __FieldGet( fieldName AS STRING ) AS USUAL
    LOCAL fieldpos := FieldPos( fieldName ) AS DWORD
    LOCAL ret := NULL AS OBJECT
    IF fieldpos == 0
        THROW Error.VoDbError( EG_ARG, EDB_FIELDNAME, __FUNCTION__,  nameof(fieldName), 1, <OBJECT>{fieldName}  )
    ELSE
         _DbThrowErrorOnFailure(__FUNCTION__, CoreDb.FieldGet( fieldpos, REF ret ))
    ENDIF
    RETURN ret
    
    
/// <summary>Access a value from a field in a workarea.</summary>
/// <param name="area">Workarea in which the expression will be evaluated.</param>
/// <param name="fieldName">FieldName to assign.</param>
/// <returns>The value of the field.</returns>
/// <example>
/// ? CUSTOMER->FirstName 
/// ? (nArea)->LastName
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when an aliased field is accessed.</remarks>
FUNCTION __FieldGetWa( area AS USUAL, fieldName AS STRING ) AS USUAL
    // XBase defines that 'M' in 'M->Name' means a Memvar
    IF area:IsNil
        RETURN __FieldGet(fieldName)
    ENDIF
    IF area:IsString .AND. ((STRING) area):ToUpper() == "M"
        RETURN __MemVarGet(fieldName)
    ENDIF
    LOCAL ret AS USUAL
    LOCAL curArea := RuntimeState.CurrentWorkarea AS DWORD
    LOCAL newArea := _Select( area ) AS DWORD
    IF newArea > 0
        RuntimeState.CurrentWorkarea := newArea
        TRY
            ret := __FieldGet( fieldName )
        FINALLY
            RuntimeState.CurrentWorkarea := curArea
        END TRY   
    ELSE
        THROW Error.VoDbError( EG_ARG, EDB_BADALIAS, __FUNCTION__, nameof(area), 1, <OBJECT>{area}  )
    ENDIF
    RETURN ret

/// <summary>Access a value from a field in a workarea, or get a property of an undeclared variable.</summary>
/// <param name="wa">Workarea in which the expression will be evaluated, or the name of the undeclared variable.</param>
/// <param name="fldName">FieldName to read or the property name to read.</param>
/// <returns>The value of the field or property.</returns>
/// <example>
/// ? Customer.LastName
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when it detects the FoxPro Member Access for an undeclare variable.</remarks>
FUNCTION __FieldGetWa2(wa AS STRING, fldName AS STRING, lAllowUndeclared AS LOGIC) AS USUAL
    LOCAL nArea := VODbGetSelect(wa) AS DWORD
    IF nArea != 0 .OR. ! lAllowUndeclared
        RETURN __FieldGetWa(wa, fldName)
    ENDIF
    LOCAL uObject := __MemVarGet(wa) AS USUAL
    RETURN IVarGet(uObject, fldName)

/// <summary>Assign a value to a field </summary>
/// <param name="area">Workarea in which the expression will be evaluated.</param>
/// <param name="fieldName">FieldName to assign.</param>
/// <param name="uValue">Value to assign.</param>
/// <returns>The return value of the is the same as the value that is assigned.</returns>
/// <example>
/// FIELD FirstName
/// FirstName := "James"
/// FIELD->LastName := "Bond"
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when a field is assigned.</remarks>
FUNCTION __FieldSet( fieldName AS STRING, uValue AS USUAL ) AS USUAL
    LOCAL fieldpos := FieldPos( fieldName ) AS DWORD
    IF fieldpos == 0
        THROW Error.VoDbError( EG_ARG, EDB_FIELDNAME, __FUNCTION__,  nameof(fieldName), 1, <OBJECT>{fieldName}  )
    ELSE
        _DbThrowErrorOnFailure(__FUNCTION__, CoreDb.FieldPut( fieldpos, uValue))
    ENDIF
    // We return the original value to allow chained expressions
    RETURN uValue
    
    
/// <summary>Assign a value to a field in a workarea.</summary>
/// <param name="area">Workarea in which the expression will be evaluated.</param>
/// <param name="fieldName">FieldName to assign.</param>
/// <param name="uValue">Value to assign.</param>
/// <returns>The return value of the is the same as the value that is assigned.</returns>
/// <example>
/// CUSTOMER->Name := "Foo"
/// (nArea)->Name := "Foo"
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when an aliased field is assigned.</remarks>
FUNCTION __FieldSetWa( area AS USUAL, fieldName AS STRING, uValue AS USUAL ) AS USUAL
    IF area:IsNil
        RETURN __FieldSet(fieldName,uValue)
    ENDIF
    IF area:IsString .AND. ((STRING) area):ToUpper() == "M"
        RETURN __MemVarPut(fieldName,uValue)
    ENDIF
    LOCAL curArea := RuntimeState.CurrentWorkarea AS DWORD
    LOCAL newArea := _Select( area ) AS DWORD
    IF newArea > 0
        RuntimeState.CurrentWorkarea := newArea
        
        TRY
            __FieldSet( fieldName, uValue )
        FINALLY
            RuntimeState.CurrentWorkarea := curArea
        END TRY   
    ELSE
        THROW Error.VoDbError( EG_ARG, EDB_BADALIAS, __FUNCTION__, nameof(area),1, <OBJECT>{area}  )
    ENDIF
    // Note: must return the same value passed in, to allow chained assignment expressions
    RETURN uValue

/// <summary>Assign a value to a field in a workarea, or set a property of an undeclared variable</summary>
/// <param name="wa">Workarea in which the expression will be evaluated, or the name of the undeclared variable.</param>
/// <param name="fldName">FieldName to assign, or the name of the property.</param>
/// <param name="uValue">Value to assign.</param>
/// <returns>The return value of the is the same as the value that is assigned.</returns>
/// <example>
/// Customer.Name = "Foo"
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when it detects the FoxPro Member Assign for an undeclare variable.</remarks>

FUNCTION __FieldSetWa2(wa AS STRING, fldName AS STRING, uValue AS USUAL,lAllowUndeclared AS LOGIC) AS USUAL
    LOCAL nArea := VODbGetSelect(wa) AS DWORD
    IF nArea != 0 .OR. ! lAllowUndeclared
        RETURN __FieldSetWa(wa, fldName,uValue)
    ENDIF
    LOCAL uObject := __MemVarGet(wa) AS USUAL
    RETURN IVarPut(uObject, fldName, uValue)


/// <summary>Evaluate an expression in a workarea.</summary>
/// <param name="area">Workarea in which the expression will be evaluated.</param>
/// <param name="action">Expression to evaluate.</param>
/// <returns>The return value of the expression that was evaluated.</returns>
/// <example>
/// uValue := CUSTOMER->(MyFunction())
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when an aliased expression is evaluated.</remarks>
FUNCTION __AreaEval<T>(area AS USUAL, action AS @@Func<T>) AS USUAL
    LOCAL curArea := RuntimeState.CurrentWorkarea AS DWORD
    LOCAL newArea := _Select( area ) AS DWORD
    LOCAL result  := DEFAULT(T) AS T
    IF newArea > 0
        RuntimeState.CurrentWorkarea := newArea
        
        TRY
            result := action()
        FINALLY
            RuntimeState.CurrentWorkarea := curArea
        END TRY   
    ELSE
        THROW Error.VoDbError( EG_ARG, EDB_BADALIAS, __FUNCTION__, nameof(area),1, <OBJECT>{area}  )
    ENDIF
    RETURN result


/// <summary>Evaluate an expression in a workarea.</summary>
/// <param name="area">Workarea in which the expression will be evaluated.</param>
/// <param name="action">Expression to evaluate.</param>
/// <returns>True when the expression is succesfully evealuated.</returns>
/// <example>
/// CUSTOMER->(DoSomething())
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when an aliased void expression is evaluated.</remarks>
FUNCTION __AreaEval(area AS USUAL, action AS System.Action) AS LOGIC
    LOCAL curArea := RuntimeState.CurrentWorkarea AS DWORD
    LOCAL newArea := _Select( area ) AS DWORD
    LOCAL result  := FALSE AS LOGIC
    IF newArea > 0
        RuntimeState.CurrentWorkarea := newArea
        TRY
            action()
            result := TRUE
        FINALLY
            RuntimeState.CurrentWorkarea := curArea
        END TRY   
    ELSE
        THROW Error.VoDbError( EG_ARG, EDB_BADALIAS, __FUNCTION__, nameof(area),1, <OBJECT>{area}  )
    ENDIF
    RETURN result
    
    
/// <summary>Access a dynamic variable.</summary>
/// <param name="cName">Name of the dynamic variable to assign.</param>
/// <param name="uValue">New value for the field.</param>
/// <example>
/// MEMVAR myName
/// ? MyName
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when a memvar is read.</remarks>
FUNCTION __MemVarGet(cName AS STRING) AS USUAL
    RETURN XSharp.MemVar.Get(cName)
    

/// <summary>Assign a new valuie to a dynamic variable.</summary>
/// <param name="cName">Name of the dynamic variable to assign.</param>
/// <param name="uValue">New value for the field.</param>
/// <example>
/// MEMVAR myName
/// MyName := "James Bond"
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when when a memvar is written.</remarks>
FUNCTION __MemVarPut(cName AS STRING, uValue AS USUAL) AS USUAL
    RETURN XSharp.MemVar.Put(cName, uValue)
    

/// <summary>Access a field in the current workarea or a dynamic variable.</summary>
/// <param name="cName">Name of the field or variable to access.</param>
/// <remarks>This function is automatically called by code generated by the compiler when an undeclared field or variable is read.
/// It may also be called when evaluating index expressions by the macro compiler, such as "Upper(LASTNAME)"
/// </remarks>
/// <example>
/// ? UndeclaredName
/// </example>
FUNCTION __VarGet(cName AS STRING) AS USUAL
    IF FieldPos(cName) > 0
        RETURN __FieldGet(cName)
    ENDIF
    RETURN __MemVarGet(cName)
    
/// <summary>Assign a field in the current workarea or a dynamic variable.</summary>
/// <remarks>This function is automatically called by code generated by the compiler when an undeclared field or variable is written.</remarks>
/// <param name="cName">Name of the field or variable to access.</param>
/// <param name="uValue">New value for the field.</param>
/// <example>
/// UndeclaredName := "James Bond"
/// </example>
FUNCTION __VarPut(cName AS STRING, uValue AS USUAL) AS USUAL
    IF FieldPos(cName) > 0
        RETURN __FieldSet(cName, uValue)
    ENDIF
    RETURN __MemVarPut(cName, uValue)
    
    
    
    // ALIAS->(DoSomething())
    // is sometimes translated to
    // __pushWorkarea( alias ) ; DoSomething() ; __popWorkArea()
    // can also be come __AreaEval(..)
    
/// <summary>Switch to a new workarea and store the current workarea on the stack.</summary>
/// <param name="alias">New area to select.</param>
/// <remarks>This function may be called by code generated by the compiler when an aliased expression is evaluated.</remarks>
FUNCTION __pushWorkarea( alias AS USUAL ) AS VOID
    LOCAL newArea := @@Select( alias ) AS DWORD
    IF newArea > 0
        RuntimeState.PushCurrentWorkarea( newArea )
    ELSE
        THROW Error.VoDbError( EG_ARG, EDB_BADALIAS, <OBJECT>{ alias } )
    ENDIF
    RETURN
    
/// <summary>Restore the current workarea from a stack after an aliased expression has been evaluated.</summary>
/// <param name="alias">New area to select.</param>
/// <remarks>This function may be called by code generated by the compiler when an aliased expression is evaluated.</remarks>
FUNCTION __popWorkarea() AS VOID
    RuntimeState.PopCurrentWorkarea()
    RETURN
    

/// <summary>Register the current dept of the privates stack.</summary>
/// <returns>The depth of the privates stack. This number must be passed to __MemVarRelease to release the newly created privates.</returns>
/// <remarks>This function is automatically called by code generated by the compiler when a function or method declares private variables.</remarks>
FUNCTION __MemVarInit() AS INT STRICT 
	RETURN XSharp.MemVar.InitPrivates()   

/// <summary>Release private variables declared at a certain level.</summary>
/// <param name="nLevel">Level which must be cleared.</param>
/// <returns>Always returns TRUE.</returns>
/// <remarks>This function is automatically called by code generated by the compiler when a function or method ends that has declared new private variables.</remarks>
FUNCTION __MemVarRelease(nLevel AS INT) AS LOGIC  STRICT
	RETURN XSharp.MemVar.ReleasePrivates(nLevel)	



/// <summary>declare a private or public variable. The private is initialized with NIL, the public variable with FALSE.</summary>
/// <param name="name">Name of the variable</param>
/// <param name="_priv">Should the variable be declared as private</param>
/// <example>
/// PUBLIC CustomerName // default value = FALSE
/// PRIVATE OrderNumber // default value = NIL
/// </example>
/// <remarks>This function is automatically called by code generated by the compiler when you use a PUBLIC or PRIVATE statement in your code</remarks>
FUNCTION __MemVarDecl(name AS STRING, _priv AS LOGIC) AS VOID  STRICT
	XSharp.MemVar.Add(name, _priv)
	RETURN 



/// <summary>Declare a local variable. The local is on the stack in the code. The codeblock allows to read/write it.</summary>
/// <param name="name">Name of the local</param>
/// <param name="cb">Get/Set codeblock</param>
/// <remarks>This function is automatically called by code generated by the compiler when use the /fox2 compiler option. <br/>
/// Declaring a local this way makes it visible to the macro compiler.</remarks>
FUNCTION __LocalRegister(name AS STRING, cb AS CODEBLOCK) AS VOID STRICT
	XSharp.MemVar.AddLocal(name, cb)


/// <summary>Undeclare a local variable, so it is no longer visible to the macro compiler.
/// The local itself is on the stack in the code. </summary>
/// <param name="name">Name of the local</param>
/// <remarks>This function is automatically called by code generated by the compiler when use the /fox2 compiler option.
/// It is used for locals with limited visibility, for example locals inside a FOR loop.</remarks>
FUNCTION __LocalUnRegister(name AS STRING) AS VOID STRICT
	XSharp.MemVar.RemoveLocal(name)


