<#--

     Copyright 2012-2016 Gunnar Morling (http://www.gunnarmorling.de/)
     and/or other contributors as indicated by the @authors tag. See the
     copyright.txt file in the distribution for a full listing of all
     contributors.

     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.

-->

<#--
  macro: handleNullCheck

  purpose: macro surrounds nested with either a source presence checker or a null check. It always uses
           a local variable. Note that the local variable assignemnt is inside the IF statement for the
           source presence check. Note also, that the else clause contains the default variable assignment if
           present.
-->
<#macro handleNullCheck>
  <#if sourcePresenceCheckerReference??>
    if ( ${sourcePresenceCheckerReference} ) {
      <@includeModel object=nullCheckLocalVarType/> ${nullCheckLocalVarName} = <@lib.handleAssignment/>;
      <#nested>
    }
  <#else>
    <@includeModel object=nullCheckLocalVarType/> ${nullCheckLocalVarName} = <@lib.handleAssignment/>;
    if ( ${nullCheckLocalVarName} != null ) {
      <#nested>
    }
  </#if>
  <#if ext.defaultValueAssignment?? >
  else {
    <@handeDefaultAssigment/>
  }
  </#if>
</#macro>

<#--
  macro: handleExceptions

  purpose: Includes the try - catch clauses around the nested code.
-->
<#macro handleExceptions>
  <#if (thrownTypes?size == 0) >
        <#nested>
  <#else>
        try {
            <#nested>
        }
        <#list thrownTypes as exceptionType>
        catch ( <@includeModel object=exceptionType/> e ) {
            throw new RuntimeException( e );
        }
        </#list>
  </#if>
</#macro>
<#--
Performs a standard assignment.
-->
<#macro handleAssignment>
    <@includeModel object=assignment
               targetBeanName=ext.targetBeanName
               existingInstanceMapping=ext.existingInstanceMapping
               targetReadAccessorName=ext.targetReadAccessorName
               targetWriteAccessorName=ext.targetWriteAccessorName
               targetType=ext.targetType/>
</#macro>
<#--
Performs a default assignment with a default value.
-->
<#macro handeDefaultAssigment>
    <@includeModel object=ext.defaultValueAssignment
               targetBeanName=ext.targetBeanName
               existingInstanceMapping=ext.existingInstanceMapping
               targetReadAccessorName=ext.targetReadAccessorName
               targetWriteAccessorName=ext.targetWriteAccessorName
               targetType=ext.targetType
               defaultValue=ext.defaultValue/>
</#macro>
<#--
  macro: handleWrite

  purpose: To handle the writing to a field or using a method. The line is not closed with ';'
-->
<#macro handleWrite>
    <#t><#if fieldAssignment> = <#nested><#else>( <#nested> )</#if>
</#macro>

<#--
  macro: handleWriteAccesing

  purpose: To handle accesing the write target type
-->
<#macro handleWriteAccesing>
    <#t><#if fieldAssignment><#else>()</#if>
</#macro>
<#--
  macro: initTargetObject

  purpose: To factorize or construct a new target object
-->
<#macro initTargetObject><@compress single_line=true>
    <#if factoryMethod??>
        <@includeModel object=factoryMethod targetType=ext.targetType/>
    <#else>
         new <@constructTargetObject/>()
    </#if>
</@compress></#macro>
<#--
  macro: constructTargetObject

  purpose: Either call the constructor of the target object directly or of the implementing type.
-->
<#macro constructTargetObject><@compress single_line=true>
    <#if ext.targetType.implementationType??>
        <@includeModel object=ext.targetType.implementationType/>
    <#else>
        <@includeModel object=ext.targetType/>
    </#if>
</@compress></#macro>
<#--
  macro: sourceLocalVarAssignment

  purpose: assigment for source local variables
-->
<#macro sourceLocalVarAssignment>
    <#if sourceLocalVarName??>
      <@includeModel object=sourceType/> ${sourceLocalVarName} = ${sourceReference};
    </#if>
</#macro>