package GDWrapper

import "base:runtime"
import "core:fmt"
import str "core:strings"
import "core:slice"
import strc "core:strconv"
import GDE "../gdextension"
import "core:math/linalg"

/**************************/
/******API WRAPPER*********/
/**************************/

/*
TODO: make it a package so that any class has acces to it.
TODO: figure out if the get proc pointed provided on init is local per instance or if it provides access equally to all extensions.
This works as a collection of helpers to call the GDExtension API
in a less verbose way, as well as a cache for methods from the discovery API,
just so we don't have to keep loading the same methods again.
*/
class_library: GDE.GDExtensionClassLibraryPtr = nil

make_property :: proc "c" (type: GDE.GDExtensionVariantType, name: cstring) -> GDE.GDExtensionPropertyInfo {
    
    return makePropertyFull(type, name, u32(GDE.PropertyHint.PROPERTY_HINT_NONE), "", "", u32(GDE.PropertyUsageFlags.PROPERTY_USAGE_DEFAULT))
}

//Odin has a bunch of memory management. If all we need is to malloc memory to heap we can do that with new().
makePropertyFull :: proc "c" (type: GDE.GDExtensionVariantType, name: cstring, hint: u32, hintString: cstring, className: cstring, usageFlags: u32) -> GDE.GDExtensionPropertyInfo {
    context = runtime.default_context()
    prop_name: =new(GDE.StringName)
    constructor.stringNameNewWithLatinChars(prop_name, name, false)

    propHintString:= new(GDE.gdstring) 
    constructor.stringNewUTF8(propHintString, hintString)

    propClassName: =new(GDE.StringName) 
    constructor.stringNameNewWithLatinChars(propClassName, className, false)
    fmt.println("make propr ", type)
    info : GDE.GDExtensionPropertyInfo = {
        name = prop_name,
        type = type, //is an enum specifying type. Meh.
        hint = hint, //Not certain what the hints do :thinking:
        hint_string = propHintString,
        class_name = propClassName,
        usage = usageFlags
    }

    return info
}

destructProperty :: proc "c" (info: ^GDE.GDExtensionPropertyInfo) {
    context = runtime.default_context()
    fmt.println("destruct propr ", info^)
    if info.name != nil{
    destructors.stringNameDestructor(info.name)
    fmt.println("destroyed prop name")}
    if info.class_name != nil {
    destructors.stringNameDestructor(info.class_name)
    fmt.println("destroyed prop classname")}
    if info.hint_string != nil {
    destructors.stringDestruction(info.hint_string)
    fmt.println("destroyed prop hintString")}
    
    fmt.println("destruct propr ", info^)
    
    if info.name != nil{
    free(info.name)
    fmt.println("free prop name")}
    if info.hint_string != nil {
    fmt.println("free to free hint")
    free(info.hint_string)
    fmt.println("free prop hintString")}
    if info.class_name != nil {
    free(info.class_name)
    fmt.println("free prop classname")}
    fmt.println("prop destroyed")
}


//using polymorphism I could go through one additional layer of function in order to create functions based on the type_id of the arguments
//make1floatargnoret($Self: typid, $Arg: typeid)
//then make a type based on the typeids of these
//Proc :: proc "c" (self: ^Self, arg: Arg)
//procs made this way will duplicate themselves as many times as necessary at compile time for each time a new variable type is used.

ptrcall_0_args_ret_float :: proc "c" (method_userdata: rawptr, p_instance: GDE.GDExtensionClassInstancePtr, p_args: GDE.GDExtensionConstTypePtr, r_ret: rawptr){
    context = runtime.default_context()
    fmt.println("point 0arg ret float")
    //ret:=r_ret
    function : proc "c" (rawptr) -> f64 = cast(proc "c" (rawptr) -> f64)method_userdata
    (cast(^f64)r_ret)^ = function(p_instance)
    // = &(function(p_instance))
}

call_0arg_ret_float :: proc "c" (method_userdata: rawptr, p_instance: GDE.GDExtensionClassInstancePtr, p_args: GDE.GDExtensionConstVariantPtrargs,
                                    p_argument_count: int, r_return: GDE.GDExtensionVariantPtr, r_error: ^GDE.GDExtensionCallError) {
    context = runtime.default_context()
    fmt.println("call no arg ret float")
    start := 0
    if p_argument_count != 0{
        r_error.error = .GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS
        r_error.expected = 0
        return
    }

    function : proc "c" (rawptr) -> f64 = cast(proc "c" (rawptr) -> f64)method_userdata
    result := function(p_instance)
    constructor.variantFromFloat(r_return, &result)

}

ptrcall_1_float_arg_no_ret :: proc "c" (method_userdata: rawptr, p_instance: GDE.GDExtensionClassInstancePtr, p_args: GDE.GDExtensionConstTypePtrargs, r_ret: GDE.GDExtensionTypePtr){
    context = runtime.default_context()
    //fmt.println("point 1float 0arg")
    //I need to handle the arguments and pass them to the function. Then return nothing.
    //only one arg, so I can typecast and get the value directly?
    function : proc "c" (rawptr, f64) = cast(proc "c" (rawptr, f64))method_userdata
    function(p_instance, (cast(^f64)p_args[0])^)
}

call_1float_arg_no_ret :: proc "c" (method_userdata: rawptr, p_instance: GDE.GDExtensionClassInstancePtr, p_args: GDE.GDExtensionConstVariantPtrargs,
                                    p_argument_count: int, r_return: GDE.GDExtensionVariantPtr, r_error: ^GDE.GDExtensionCallError) {
    
    context = runtime.default_context()
    //fmt.println("call 1arg ret 0")
    if p_argument_count < 1 {
        r_error.error = .GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS
        r_error.expected = 1
        fmt.println("error small")
        return
    }
    if p_argument_count > 1 {
        r_error.error = .GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS
        r_error.expected = 1
        fmt.println("error big")
        return
    }

    type : GDE.GDExtensionVariantType = api.variantGetType(p_args[0])
    if type != .FLOAT {
        r_error.error = .GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT
        r_error.expected = i32(GDE.GDExtensionVariantType.FLOAT)
        fmt.println("error wrong type")
        return
    }
    
    // Extract the argument.
    arg1: f64;
    constructor.floatFromVariant(&arg1, cast(GDE.GDExtensionVariantPtr)p_args[0]);
    //Variants are special things, so probably do just need to rely on Godot's type conversion.
    fmt.println("Variant from Godot: ",arg1)

    //Call function.
    function: proc "c" (rawptr, f64) = cast(proc "c" (rawptr, f64))method_userdata
    function(p_instance, arg1)
}

call_2_args_stringname_vector2_no_ret_variant :: proc "c" (p_method_bind: GDE.GDExtensionMethodBindPtr, p_instance: GDE.GDExtensionObjectPtr, p_arg1: GDE.GDExtensionTypePtr, p_arg2: GDE.GDExtensionTypePtr) {
    context = runtime.default_context()
    // Set up the arguments for the call.
    fmt.println("Signal bind call?")
    arg1: GDE.Variant
    constructor.variantFromStringNameConstructor(&arg1, p_arg1)
    arg2: GDE.Variant
    constructor.variantFromVec2Constructor(&arg2, p_arg2)
    //args: GDE.GDExtensionConstVariantPtrargs = {&arg1, &arg2};
    varSet:= [?]rawptr {&arg1, &arg2}

    // Add dummy return value storage.
    ret: GDE.Variant

    // Call the function.
    api.objectMethodBindCall(p_method_bind, p_instance, raw_data(varSet[:]), 2, &ret, nil)

    // Destroy the arguments that need it.
    destructors.variantDestroy(&arg1)
    destructors.variantDestroy(&ret)
}

//******************************\\
//*******METHOD BINDDINGS*******\\
//******************************\\
bindMethod0r :: proc "c" (className: cstring, methodName: cstring, function: rawptr, returnType: GDE.GDExtensionVariantType) {
    context = runtime.default_context()
    fmt.println("bind 0r")
    methodStringName: GDE.StringName
    constructor.stringNameNewWithLatinChars(&methodStringName, methodName, false)

    call_func: GDE.GDExtensionClassMethodCall = cast(GDE.GDExtensionClassMethodCall)call_0arg_ret_float
    ptrcall: GDE.GDExtensionClassMethodPtrCall = cast(GDE.GDExtensionClassMethodPtrCall)ptrcall_0_args_ret_float

    fmt.println("call and ptr assigned")
    returnInfo: GDE.GDExtensionPropertyInfo = make_property(returnType, "123")
    fmt.println("property made ", returnInfo)
    fmt.println("value at name ", (cast(^GDE.gdstring)returnInfo.name)^)

    methodInfo : GDE.GDExtensionClassMethodInfo = {
        name = &methodStringName,
        method_userdata = function,
        call_func = call_func,
        ptrcall_func = ptrcall,
        method_flags = u32(GDE.GDExtensionClassMethodFlags.DEFAULT),
        has_return_value = true,
        return_value_info = &returnInfo,
        return_value_metadata = GDE.GDExtensionClassMethodArgumentMetadata.NONE,
        argument_count = 0
    }
    fmt.println("method info set")
    classNameString: GDE.StringName
    constructor.stringNameNewWithLatinChars(&classNameString, className, false)

    api.classdbRegisterExtensionClassMethod(class_library, &classNameString, &methodInfo)
    fmt.println("class registered 0r")
    //Destructor things.
    destructors.stringNameDestructor(&methodStringName)
    fmt.println("destroyed 0r")
    destructors.stringNameDestructor(&classNameString)
    fmt.println("destroyed 0r")
    destructProperty(&returnInfo)
    
    fmt.println("destroyed 0r")

}

bindMethod1 :: proc "c" (className: cstring, methodName: cstring, function: rawptr, arg1Name: cstring, arg1Type: GDE.GDExtensionVariantType) {
    context = runtime.default_context()
    fmt.println("bind 1r")
    methodNameString: GDE.StringName
    constructor.stringNameNewWithLatinChars(&methodNameString, methodName, false)

    callFunc: GDE.GDExtensionClassMethodCall = cast(GDE.GDExtensionClassMethodCall)call_1float_arg_no_ret
    ptrcallFunc: GDE.GDExtensionClassMethodPtrCall = cast(GDE.GDExtensionClassMethodPtrCall)ptrcall_1_float_arg_no_ret

    arg1NameString: GDE.StringName
    //constructor.stringNameNewWithLatinChars(&arg1NameString, arg1Name, false)

    argsInfo:= [1]GDE.GDExtensionPropertyInfo {make_property(arg1Type, arg1Name)}

    args_metadata := [1]GDE.GDExtensionClassMethodArgumentMetadata{GDE.GDExtensionClassMethodArgumentMetadata.NONE}

    methodInfo: GDE.GDExtensionClassMethodInfo = {
        name = &methodNameString,
        method_userdata = function,
        call_func = callFunc,
        ptrcall_func = ptrcallFunc,
        method_flags = u32(GDE.GDExtensionClassMethodFlags.DEFAULT),
        has_return_value = false,
        argument_count = 1,
        arguments_info = &argsInfo[0],
        arguments_metadata = &args_metadata[0],
    }
    fmt.println("method info set")
    classNameString: GDE.StringName
    constructor.stringNameNewWithLatinChars(&classNameString, className, false)

    fmt.println("New string.")
    api.classdbRegisterExtensionClassMethod(class_library, &classNameString, &methodInfo)
    fmt.println("method registered 1r.")
    //Destroy things.
    //destructors.stringNameDestructor(&methodNameString)
    //fmt.println("method dest method name string.")
    //destructors.stringNameDestructor(&classNameString)
    //fmt.println("method dest class name string.")
    destructProperty(&argsInfo[0])
    fmt.println("r1 method created")
}

bindProperty :: proc "c" (className, name: cstring, type: GDE.GDExtensionVariantType, getter, setter: cstring){
    context = runtime.default_context()
    
    classNameString: GDE.StringName
    constructor.stringNameNewWithLatinChars(&classNameString, className, false)
    info: GDE.GDExtensionPropertyInfo = make_property(type, name)

    getterName: GDE.StringName
    constructor.stringNameNewWithLatinChars(&getterName, getter, false)

    setterName: GDE.StringName
    constructor.stringNameNewWithLatinChars(&setterName, setter, false)
    
    fmt.println("register property")
    api.classdbRegisterExtensionClassProperty(class_library, &classNameString, &info, &setterName, &getterName)
    fmt.println("register property complete")

    //Destructor stuff
    destructProperty(&info)
}

//Bind virtual functions.
//These will be things like process, physics and I assume other functions that would normally be inherited from the parent node type?

//Checks for match on the function StringName
isStringNameEqual :: proc "c" (p_left: GDE.GDExtensionConstStringNamePtr, p_right: cstring) -> (retEqual: bool){
    context = runtime.default_context()
    p_stringName: GDE.StringName
    constructor.stringNameNewWithLatinChars(&p_stringName, p_right, false)

    operator.stringNameEqual(p_left, &p_stringName, &retEqual)
    fmt.println("left: ", (cast(^GDE.StringName)p_left).data, "right: ", p_stringName.data)
    fmt.println(retEqual)

    destructors.stringNameDestructor(&p_stringName)

    return
}
//btw, I had to go through so many functions to get to being able to use the function above that I forgot this was the final function I was supposed to use.

//OPERATORS\\
Operators :: struct {
    //From what I can tell StringNames are just arrays of data. Odin supports array comparison up to a certain point, so we can likely do this ourselves.
    stringNameEqual: GDE.GDExtensionPtrOperatorEvaluator
}

//*****************\\
//*****SIGNALS*****\\
//*****************\\

bindSignal1 :: proc "c" (className, signalName, arg1Name: cstring, arg1Type: GDE.GDExtensionVariantType){
    context = runtime.default_context()

    classStringName: GDE.StringName
    constructor.stringNameNewWithLatinChars(&classStringName, className, false)
    signalStringName: GDE.StringName
    constructor.stringNameNewWithLatinChars(&signalStringName, signalName, false)

    args_info: []GDE.GDExtensionPropertyInfo = {
        make_property(arg1Type, arg1Name),
    }

    api.classBDRegistClassSignal(class_library, &classStringName, &signalStringName, raw_data(args_info), 1)

    // Destruct things.
    destructors.stringNameDestructor(&classStringName)
    destructors.stringNameDestructor(&signalStringName)
    destructProperty(&args_info[0])
}

operator: Operators

//*****************************\\
//******Pointers to Godot******\\
//**********Functions**********\\

Constructors :: struct {
    stringNameNewWithLatinChars: GDE.GDExtensionInterfaceStringNameNewWithLatin1Chars,
    stringNewUTF8: GDE.GDExtensionInterfaceStringNewWithUtf8Chars,
    variantFromFloat: GDE.GDExtensionVariantFromTypeConstructorFunc,
    floatFromVariant: GDE.GDExtensionTypeFromVariantConstructorFunc,
    //If this is just to handle vector stuff because C and C++ are terrible at this I'mma bust. This is a [2]f32. Easy to play with in Odin.
    vector2ConstructorXY: GDE.GDExtensionPtrConstructor,
    //^^^^Dude it's a vec2. Of course it's XY. What else is it gonna be? Sorry, tired of all this redundency in the names. -_- there is a vector2i. Which is the same in int.
    variantFromStringNameConstructor: GDE.GDExtensionVariantFromTypeConstructorFunc,
    variantFromVec2Constructor: GDE.GDExtensionVariantFromTypeConstructorFunc,
    variantNil: GDE.GDExtensionInterfaceVariantNewNil,
    variantToVec2Constructor: GDE.GDExtensionTypeFromVariantConstructorFunc,
}

constructor : Constructors

Destructors :: struct {
    stringNameDestructor: GDE.GDExtensionPtrDestructor,
    stringDestruction: GDE.GDExtensionPtrDestructor,
    variantDestroy: GDE.GDExtensionInterfaceVariantDestroy
}

destructors: Destructors

//signals stuff
Methods :: struct {
    node2dSetPosition: GDE.GDExtensionMethodBindPtr,
    objectEmitSignal: GDE.GDExtensionMethodBindPtr,
    node2dGetPos: GDE.GDExtensionMethodBindPtr,
}

methods: Methods

API :: struct {
    classDBRegisterExtensionClass4: GDE.GDExtensionInterfaceClassdbRegisterExtensionClass4,
    classdbConstructObject: GDE.GDExtensionInterfaceClassdbConstructObject,
    object_set_instance: GDE.GDExtensionInterfaceObjectSetInstance,
    object_set_instance_binding: GDE.GDExtensionInterfaceObjectSetInstanceBinding,
    mem_alloc: GDE.GDExtensionInterfaceMemAlloc,
    mem_free: GDE.GDExtensionInterfaceMemFree,
    p_get_proc_address: GDE.InterfaceGetProcAddress,
    //functions related to method bindings
    getVariantFromTypeConstructor: GDE.GDExtensionInterfaceGetVariantFromTypeConstructor,
    getVariantToTypeConstuctor: GDE.GDExtensionInterfaceGetVariantToTypeConstructor,
    variantGetType: GDE.GDExtensionInterfaceVariantGetType,
    classdbRegisterExtensionClassMethod: GDE.GDExtensionInterfaceClassdbRegisterExtensionClassMethod,
    //custom properties
    classdbRegisterExtensionClassProperty: GDE.GDExtensionInterfaceClassdbRegisterExtensionClassProperty,
    clasDBGetMethodBind: GDE.GDExtensionInterfaceClassdbGetMethodBind,
    objectMethodBindPtrCall: GDE.GDExtensionInterfaceObjectMethodBindPtrcall,
    classBDRegistClassSignal: GDE.GDExtensionInterfaceClassdbRegisterExtensionClassSignal,
    objectMethodBindCall: GDE.GDExtensionInterfaceObjectMethodBindCall,
}

api: API

loadAPI :: proc "c" (p_get_proc_address: GDE.InterfaceGetProcAddress){
    context = runtime.default_context()
    // Get helper functions first.
    //Gets a pointer to the function that will return the pointer to the function that destroys the specific variable type.
    variant_get_ptr_destructor: GDE.GDExtensionInterfaceVariantGetPtrDestructor  = cast(GDE.GDExtensionInterfaceVariantGetPtrDestructor)p_get_proc_address("variant_get_ptr_destructor")
    //Gets a pointer to the function that will return the pointer to the function that will evaluate the variable types under the specified condition.
    variantGetPtrOperatorEvaluator: GDE.GDExtensionInterfaceVariantGetPtrOperatorEvaluator = cast(GDE.GDExtensionInterfaceVariantGetPtrOperatorEvaluator)p_get_proc_address("variant_get_ptr_operator_evaluator")
    variantGetPtrConstructor: GDE.GDExtensionInterfaceVariantGetPtrConstructor = cast(GDE.GDExtensionInterfaceVariantGetPtrConstructor)p_get_proc_address("variant_get_ptr_constructor")

    //Operators
    //Do not get confused with the function that we run on our end that will return whether a StringName is equal. This just runs the compare on Godot Side.
    operator.stringNameEqual = variantGetPtrOperatorEvaluator(.VARIANT_OP_EQUAL, .STRING_NAME, .STRING_NAME)

    //API.
    api.classDBRegisterExtensionClass4 = cast(GDE.GDExtensionInterfaceClassdbRegisterExtensionClass4)p_get_proc_address("classdb_register_extension_class4")
    api.classdbConstructObject = cast(GDE.GDExtensionInterfaceClassdbConstructObject)p_get_proc_address("classdb_construct_object")
    api.object_set_instance = cast(GDE.GDExtensionInterfaceObjectSetInstance)p_get_proc_address("object_set_instance")
    api.object_set_instance_binding = cast(GDE.GDExtensionInterfaceObjectSetInstanceBinding)p_get_proc_address("object_set_instance_binding")
    api.mem_alloc = cast(GDE.GDExtensionInterfaceMemAlloc)p_get_proc_address("mem_alloc")
    api.mem_free = cast(GDE.GDExtensionInterfaceMemFree)p_get_proc_address("mem_free")
    api.p_get_proc_address = p_get_proc_address
    api.getVariantFromTypeConstructor = cast(GDE.GDExtensionInterfaceGetVariantFromTypeConstructor)p_get_proc_address("get_variant_from_type_constructor")
    api.getVariantToTypeConstuctor = cast(GDE.GDExtensionInterfaceGetVariantToTypeConstructor)p_get_proc_address("get_variant_to_type_constructor")
    api.variantGetType = cast(GDE.GDExtensionInterfaceVariantGetType)p_get_proc_address("variant_get_type")
    api.classdbRegisterExtensionClassMethod = cast(GDE.GDExtensionInterfaceClassdbRegisterExtensionClassMethod)p_get_proc_address("classdb_register_extension_class_method")
    api.classdbRegisterExtensionClassProperty = cast(GDE.GDExtensionInterfaceClassdbRegisterExtensionClassProperty)p_get_proc_address("classdb_register_extension_class_property")
    //Really nice that you can (hopefully) just cast the pointer to the function's proc type. Signature?
    api.clasDBGetMethodBind = cast(GDE.GDExtensionInterfaceClassdbGetMethodBind)p_get_proc_address("classdb_get_method_bind")
    //api.objectMethodBindPtrCall = cast(proc(p_method_bind: GDE.GDExtensionMethodBindPtr, p_instance: GDE.GDExtensionObjectPtr, p_args: GDE.GDExtensionConstTypePtrargs, r_ret: GDE.GDExtensionTypePtr))p_get_proc_address("object_method_bind_ptrcall")
    api.objectMethodBindPtrCall = cast(GDE.GDExtensionInterfaceObjectMethodBindPtrcall)p_get_proc_address("object_method_bind_ptrcall")
    api.classBDRegistClassSignal = cast(GDE.GDExtensionInterfaceClassdbRegisterExtensionClassSignal)p_get_proc_address("classdb_register_extension_class_signal")
    api.objectMethodBindCall = cast(GDE.GDExtensionInterfaceObjectMethodBindCall)p_get_proc_address("object_method_bind_call")

    //constructors.
    constructor.stringNameNewWithLatinChars = cast(GDE.GDExtensionInterfaceStringNameNewWithLatin1Chars)p_get_proc_address("string_name_new_with_latin1_chars")
    constructor.variantFromFloat = api.getVariantFromTypeConstructor(.FLOAT)
    constructor.floatFromVariant = api.getVariantToTypeConstuctor(.FLOAT)
    constructor.stringNewUTF8 = cast(GDE.GDExtensionInterfaceStringNewWithUtf8Chars)api.p_get_proc_address("string_new_with_utf8_chars")
    constructor.vector2ConstructorXY = variantGetPtrConstructor(.VECTOR2, 3) // See extension_api.json for indices. ??? So... a Vector2 isn't generic like it is in Raylib. It has specific names for each use case. Madness.
    //What happens if you don't use the correct index? Does Godot throw a fit because the names aren't exactly the same?
    //Is this what a dynamic language ends up being?
    constructor.variantFromStringNameConstructor = api.getVariantFromTypeConstructor(.STRING_NAME)
    constructor.variantFromVec2Constructor = api.getVariantFromTypeConstructor(.VECTOR2)
    constructor.variantNil = cast(GDE.GDExtensionInterfaceVariantNewNil)api.p_get_proc_address("variant_new_nil")
    constructor.variantToVec2Constructor = cast(GDE.GDExtensionTypeFromVariantConstructorFunc)api.getVariantToTypeConstuctor(.VECTOR2)

    //Destructors.
    destructors.stringNameDestructor = cast(GDE.GDExtensionPtrDestructor)variant_get_ptr_destructor(.STRING_NAME)
    destructors.stringDestruction = cast(GDE.GDExtensionPtrDestructor)variant_get_ptr_destructor(.STRING)
    destructors.variantDestroy = cast(GDE.GDExtensionInterfaceVariantDestroy)p_get_proc_address("variant_destroy")

}