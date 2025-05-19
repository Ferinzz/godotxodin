//Godot C guide : https://docs.godotengine.org/en/latest/tutorials/scripting/gdextension/gdextension_c_example.html
//Godo cmd options : https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html
//launch scene directly with godot [path to scene] --Path [path to godot file]
//Community built Godot Bindings (Includes generator) : https://github.com/dresswithpockets/odin-godot
//TODO: build from source to be able to debug the engine errors. Currently they tell me NOTHING and their functions provide no error return. Madness.
//Debugger setup instructions? Requires building from source : https://www.reddit.com/r/godot/comments/11d56t1/gdextension_how_to_get_debugger_working_when/
//https://godotforums.org/d/32073-debug-c-gdextension/16
package main

import "base:runtime"
import "core:fmt"
import str "core:strings"
import "core:slice"
import strc "core:strconv"
import GDE "gdextension"
import "core:math/linalg"


//main :: proc "c" () {
//    fmt.println("CORE")
//}


/******************/
/******************/
/*******DEFS********/
/******************/
/******************/
//optional in Godot. These are mainly to define pointer etc variable lengths in C.
StringName:: struct{
    data: [8]u8
}
gdstring:: struct{
    data: [8]u8
}

//The use 16 if your Godot version was built with double precision support, which is not the default.
//else use 8
Vector2 :: struct {
    data: [8]u8,
}

PropertyHint :: enum {
    PROPERTY_HINT_NONE
}

PropertyUsageFlags :: enum {
    PROPERTY_USAGE_NONE,
    PROPERTY_USAGE_STORAGE = 2,
    PROPERTY_USAGE_EDITOR = 4,
    PROPERTY_USAGE_DEFAULT = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
}

icon:= "res://icon.svg"



/******************************/
/**********INITIALIZATION******/
/******************************/

//ENTRY POINT: This name needs to match the name in the gdexample.gdextension file.
//If the name does not match, Godot will not know where/how to bind to function.
@export
gdexample_library_init :: proc "contextless" (p_get_proc_address : GDE.InterfaceGetProcAddress, p_library: GDE.GDExtensionClassLibraryPtr, r_initialization: ^GDE.GDExtensionInitialization) -> b8 {
    context = runtime.default_context()
    class_library = p_library
    loadAPI(p_get_proc_address)
    fmt.println("1")


    /* This function will be called multiple times for each initialization level. */
    r_initialization.initialize   = initialize_gdexample_module
    r_initialization.deinitialize = deinitialize_gdexample_module
    r_initialization.userdata     = nil
    r_initialization.minimum_initialization_level = .INITIALIZATION_SCENE


    return true
}

//TODO: figure out if you can create multiple classes from a single init module.
initialize_gdexample_module :: proc "c" (p_userdata: rawptr, p_level:  GDE.InitializationLevel){
    if p_level != .INITIALIZATION_SCENE{
        return
    }
    context = runtime.default_context()
    fmt.println("AAAAAAAAAaaaaaaahhhh")

    
    // Get ClassDB methods here because the classes we need are all properly registered now.
    // See extension_api.json for hashes.
    native_class_name: StringName;
    method_name: StringName;

    constructor.stringNameNewWithLatinChars(&native_class_name, "Node2D", false);
    constructor.stringNameNewWithLatinChars(&method_name, "set_position", false);
    methods.node2dSetPosition = api.clasDBGetMethodBind(&native_class_name, &method_name, 743155724);
    destructors.stringNameDestructor(&native_class_name);
    destructors.stringNameDestructor(&method_name);

    class_name: StringName
    constructor.stringNameNewWithLatinChars(&class_name, "GDExample", false)
    parent_class_name: StringName
    constructor.stringNameNewWithLatinChars(&parent_class_name, "Sprite2D", false)

    stringptr:gdstring
    getVariant : GDE.GDExtensionVariantPtr
    getVariant = api.p_get_proc_address("variant_new_nil")
    //GDE.GDExtensionInterfaceVariantNewNil(cast(GDE.GDExtensionUninitializedVariantPtr)stringptr)
    fmt.println("AAAAAAAAAfter variant")

    
    //Will need to destroy with GDExtensionInterfaceVariantGetPtrDestructor -> GDExtensionPtrDestructor.
    //Setup destructor getter with enums. GDEXTENSION_VARIANT_TYPE_STRING
    stringraw: rawptr
    makestring : GDE.GDExtensionInterfaceStringNewWithLatin1Chars
    makestring = cast(GDE.GDExtensionInterfaceStringNewWithLatin1Chars)api.p_get_proc_address("string_new_with_latin1_chars")
    mystring:=str.clone_to_cstring(icon)
    
    //Does indeed create a string in some kind of memory.
    makestring(&stringraw, mystring)
    //Pointers just need to be packed data of the correct bit length. The type gdstring was declared above.
    //Though maybe Godot expects a struct format for their templates.
    //stringgd: gdstring
    //makestring(&stringgd, "res://icon.svg")
    //But odin takes care of sizing based on 32 or 64 bit, so just us rawptr.
    
    fmt.println("AAAAAAAAAfter string")
    //To get access to the string you need to cast it to another pointer type then dereference.
    //To properly handle this directly we'd need to be able to know the underlying memory setup of a C++ string.
    //fmt.println((cast(^i8)stringraw)^)

    //Will need to get more info about how these settings affect classes. Ex runtime?
    class_info: GDE.GDExtensionClassCreationInfo4 = {
        is_virtual = false,
        is_abstract = false,
        is_exposed = true,
        is_runtime = false,
        icon_path = &stringraw,
        set_func = nil,
        get_func = nil,
        get_property_list_func = nil,
        free_property_list_func = nil,
        property_can_revert_func = nil,
        property_get_revert_func = nil,
        validate_property_func = nil,
        notification_func = nil,
        to_string_func = nil,
        reference_func = nil,
        unreference_func = nil,
        create_instance_func = gdexampleClassCreateInstance,
        free_instance_func = gdexampleClassFreeInstance,
        recreate_instance_func = nil,
        get_virtual_func = nil,
        get_virtual_call_data_func = getVirtualWithData,
        call_virtual_with_data_func = callVirtualFunctionWithData,
        class_userdata = nil,
    }
    fmt.println("AAAAAAAAAaafter struct")

    api.classDBRegisterExtensionClass4(class_library, &class_name, &parent_class_name, &class_info)
    fmt.println("AAAAAAAAAaaaaaaahhhh", &class_library, &class_name, &parent_class_name, &class_info)
    
    gdexample_class_bind_method()
    fmt.println("binding completed")


    destructors.stringNameDestructor(&class_name)
    destructors.stringNameDestructor(&parent_class_name)

}

deinitialize_gdexample_module :: proc "c" (p_userdata: rawptr, p_level: GDE.InitializationLevel){

}


//Create instance will always run on program launch regardless if it's in the scene or not.
//This will also run when the scene starts. Once for each instance of the Node present in the tree.
gdexampleClassCreateInstance :: proc "c" (p_class_user_data: rawptr, p_notify_postinitialize: GDE.GDExtensionBool) -> GDE.GDExtensionObjectPtr {
    context = runtime.default_context()

    fmt.println("2222222222")
    
    //create native Godot object.
    //Here we create an object that is part of Godot core library.
    class_name : StringName
    constructor.stringNameNewWithLatinChars(&class_name, "Sprite2D", false)
    object: GDE.GDExtensionObjectPtr = api.classdbConstructObject(&class_name)
    destructors.stringNameDestructor(&class_name)

    //Create extension object.
    //Can replace with new(). Just need to create the struct and pass a pointer.
    self: ^GDExample = cast(^GDExample)api.mem_alloc(size_of(GDExample))
    //constructor is called after creation. Sets the defaults.
    //Pretty sure the doc info about defaults uses this.
    class_constructor(self)
    self.object = object

    //Set extension instance in the native Godot object.
    constructor.stringNameNewWithLatinChars(&class_name, "GDExample", false)
    api.object_set_instance(object, &class_name, self)
    api.object_set_instance_binding(object, class_library, self, classBindingCallbacks)

    //Heap cleanup.
    destructors.stringNameDestructor(&class_name)

    return object
}

//WARNING : Free any heap memory allocated within this context.
//There's also a destructor, so what's the difference?
//Does destructor just clear the variable data and this is supposed to clear the class itself?
//Maybe it's so that destructor can be run when making editor changes like reset?
gdexampleClassFreeInstance :: proc "c" (p_class_userdata: rawptr, p_instance: GDE.GDExtensionClassInstancePtr) {
    context = runtime.default_context()
    if (p_instance == nil){
        return
    }
    self : ^GDExample = cast(^GDExample)p_instance
    class_destructor(self)
    api.mem_free(self)
}


gdexample_class_bind_method :: proc "c" () {
    context = runtime.default_context()
    fmt.println("bind methods")
    bindMethod0r("GDExample", "get_amplitude", cast(rawptr)ClassGetAmplitude, .FLOAT)
    bindMethod1("GDExample", "set_amplitude", cast(rawptr)ClassSetAmplitude, "amplitude", .FLOAT)
    bindProperty("GDExample", "amplitude", .FLOAT, "get_amplitude", "set_amplitude");

    
    bindMethod0r("GDExample", "get_speed", cast(rawptr)ClassGetSpeed, .FLOAT)
    bindMethod1("GDExample", "set_speed", cast(rawptr)ClassSetSpeed, "speed", .FLOAT)
    bindProperty("GDExample", "speed", .FLOAT, "get_speed", "set_speed");
}

//This is where you would set your defaults.
//Seeing as both the create and construct are called when something is made I wonder if this is just redundency or trying to make things more C++ styled despite it not needing to be.
//Odin defaults everything to 0 regardless, so maybe not as horrible if you forget some?
//Using the reset button doesn't even call this thing.
class_constructor :: proc "c" (self: ^GDExample) {
    context = runtime.default_context()
    fmt.println("class constructor")
    self.amplitude = 10
    self.speed = 1
    self.timePassed = 0
}

class_destructor  :: proc  "c" (self: ^GDExample) {
    context = runtime.default_context()

}


//*************************\\
//*****Class Variables*****\\
//*************************\\

//struct to hold node data
//This struct should hold the class variables. (following the C guide)
GDExample :: struct{
    //public properties. Could be functions pointers?
    amplitude: f64,
    speed: f64,
    object: GDE.GDExtensionObjectPtr, //stores the underlying Godot data

    //''''''private''''''' variables.
    timePassed: f64,
}

//****************************\\
//******Functions/Methods*****\\
//****************************\\

//Wew, OOP Getter setters. /s
//Really hope there's a way to properly expose variables to the rest of the programs
//and apparently not. exposing a property to the editor requires you to provide a getter and setter for the editor to fetch and update the value.
//The getter and setter are called every.single.tick. Don't make one that's too expensive.
ClassSetAmplitude :: proc "c" (self: ^GDExample, amplitude: f64) {
    self.amplitude = amplitude
}

ClassGetAmplitude :: proc "c" (self: ^GDExample) -> f64 {
    context = runtime.default_context()
    return self.amplitude
}

ClassSetSpeed :: proc "c" (self: ^GDExample, speed: f64) {
    self.speed = speed
}

ClassGetSpeed :: proc "c" (self: ^GDExample) -> f64 {
    context = runtime.default_context()
    return self.speed
}

//*****************************\\
//************Godot************\\
//******Virtual Functions******\\

classProcess :: proc "c" (self: ^GDExample, delta: f64) {
    context = runtime.default_context()
    fmt.println("Delta time: ",delta)
    self.timePassed += self.speed * delta
    newPosition: Vector2

    
    // Set up the arguments for the Vector2 constructor.
    x: f64 = self.amplitude + (self.amplitude * linalg.sin(self.timePassed * 2.0));
    y: f64 = self.amplitude + (self.amplitude * linalg.cos(self.timePassed * 1.5));
    vect2: = [?]rawptr {&x, &y}
    args: GDE.GDExtensionConstTypePtrargs 
    args = raw_data(vect2[:])
    // Call the Vector2 constructor.
    constructor.vector2ConstructorXY(&newPosition, args);

    args2 := [?]rawptr {&newPosition}
    // Set up the arguments for the set_position method.
    //args2: GDE.GDExtensionConstTypePtrargs = {&newPosition};
    // Call the set_position method.
    api.objectMethodBindPtrCall(methods.node2dSetPosition, self.object, raw_data(args2[:]), nil);
}

//*****************************\\
//*******Godot Callbacks*******\\
//*****************************\\
getVirtualWithData :: proc "c" (p_class_userdata: rawptr, p_name: GDE.GDExtensionConstStringNamePtr, p_hash: u32) -> rawptr {
    context = runtime.default_context()

    if isStringNameEqual(p_name, "_process") {
        fmt.println("process pointer got")
        return cast(rawptr)classProcess
    }

    return nil
}

callVirtualFunctionWithData :: proc "c" (p_instance: rawptr, p_name: GDE.GDExtensionConstStringNamePtr, p_virtual_call_userdata: rawptr, p_args: GDE.GDExtensionConstTypePtrargs, r_ret: GDE.GDExtensionTypePtr) {
    context = runtime.default_context()
    //fmt.println("p_virtual_call_userdata: ", p_virtual_call_userdata)
    //fmt.println("classProcess: ", classProcess)
    //Godot provides the exact pointer for our function.
    if p_virtual_call_userdata == cast(rawptr)classProcess {
        fmt.println("process called.")
        ptrcall_1_float_arg_no_ret(p_virtual_call_userdata, p_instance, p_args, r_ret)
    }
}

//Need to setup a way to provide pointers to the above.
//Wrappers for specific proc calls added to API.


classBindingCallbacks: GDE.GDExtensionInstanceBindingCallbacks = {
    create_callback    = nil,
    free_callback      = nil,
    reference_callback = nil
}

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
    
    return makePropertyFull(type, name, u32(PropertyHint.PROPERTY_HINT_NONE), "", "", u32(PropertyUsageFlags.PROPERTY_USAGE_DEFAULT))
}

//Odin has a bunch of memory management. If all we need is to malloc memory to heap we can do that with new().
makePropertyFull :: proc "c" (type: GDE.GDExtensionVariantType, name: cstring, hint: u32, hintString: cstring, className: cstring, usageFlags: u32) -> GDE.GDExtensionPropertyInfo {
    context = runtime.default_context()
    prop_name: =new(StringName)
    constructor.stringNameNewWithLatinChars(prop_name, name, false)

    propHintString:= new(gdstring) 
    constructor.stringNewUTF8(propHintString, hintString)

    propClassName: =new(StringName) 
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
    fmt.println("point 1float 0arg")
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

//******************************\\
//*******METHOD BINDDINGS*******\\
//******************************\\
bindMethod0r :: proc "c" (className: cstring, methodName: cstring, function: rawptr, returnType: GDE.GDExtensionVariantType) {
    context = runtime.default_context()
    fmt.println("bind 0r")
    methodStringName: StringName
    constructor.stringNameNewWithLatinChars(&methodStringName, methodName, false)

    call_func: GDE.GDExtensionClassMethodCall = cast(GDE.GDExtensionClassMethodCall)call_0arg_ret_float
    ptrcall: GDE.GDExtensionClassMethodPtrCall = cast(GDE.GDExtensionClassMethodPtrCall)ptrcall_0_args_ret_float

    fmt.println("call and ptr assigned")
    returnInfo: GDE.GDExtensionPropertyInfo = make_property(returnType, "123")
    fmt.println("property made ", returnInfo)
    fmt.println("value at name ", (cast(^gdstring)returnInfo.name)^)

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
    classNameString: StringName
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
    methodNameString: StringName
    constructor.stringNameNewWithLatinChars(&methodNameString, methodName, false)

    callFunc: GDE.GDExtensionClassMethodCall = cast(GDE.GDExtensionClassMethodCall)call_1float_arg_no_ret
    ptrcallFunc: GDE.GDExtensionClassMethodPtrCall = cast(GDE.GDExtensionClassMethodPtrCall)ptrcall_1_float_arg_no_ret

    arg1NameString: StringName
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
    classNameString: StringName
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
    
    classNameString: StringName
    constructor.stringNameNewWithLatinChars(&classNameString, className, false)
    info: GDE.GDExtensionPropertyInfo = make_property(type, name)

    getterName: StringName
    constructor.stringNameNewWithLatinChars(&getterName, getter, false)

    setterName: StringName
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
    p_stringName: StringName
    constructor.stringNameNewWithLatinChars(&p_stringName, p_right, false)

    operator.stringNameEqual(p_left, &p_stringName, &retEqual)
    fmt.println("left: ", (cast(^StringName)p_left).data, "right: ", p_stringName.data)
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
    vector2ConstructorXY: GDE.GDExtensionPtrConstructor
    //^^^^Dude it's a vec2. Of course it's XY. What else is it gonna be? Sorry, tired of all this redundency in the names. -_- there is a vector2i. Which is the same in int.
}

constructor : Constructors

Destructors :: struct {
    stringNameDestructor: GDE.GDExtensionPtrDestructor,
    stringDestruction: GDE.GDExtensionPtrDestructor
}

destructors: Destructors

//signals stuff
Methods :: struct {
    node2dSetPosition: GDE.GDExtensionMethodBindPtr,
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

    //constructors.
    constructor.stringNameNewWithLatinChars = cast(GDE.GDExtensionInterfaceStringNameNewWithLatin1Chars)p_get_proc_address("string_name_new_with_latin1_chars")
    constructor.variantFromFloat = api.getVariantFromTypeConstructor(.FLOAT)
    constructor.floatFromVariant = api.getVariantToTypeConstuctor(.FLOAT)
    constructor.stringNewUTF8 = cast(GDE.GDExtensionInterfaceStringNewWithUtf8Chars)api.p_get_proc_address("string_new_with_utf8_chars")
    constructor.vector2ConstructorXY = variantGetPtrConstructor(.VECTOR2, 3) // See extension_api.json for indices. ??? So... a Vector2 isn't generic like it is in Raylib. It has specific names for each use case. Madness.
    //What happens if you don't use the correct index? Does Godot throw a fit because the names aren't exactly the same?
    //Is this what a dynamic language ends up being?

    //Destructors.
    destructors.stringNameDestructor = cast(GDE.GDExtensionPtrDestructor)variant_get_ptr_destructor(.STRING_NAME)
    destructors.stringDestruction = cast(GDE.GDExtensionPtrDestructor)variant_get_ptr_destructor(.STRING)

}