package main

import "base:runtime"
import "core:fmt"
import str "core:strings"
import "core:slice"
import strc "core:strconv"
import GDE "gdextension"

//main :: proc() {
//    fmt.println("CORE")
//}


/******************/
/******************/
/*******DEFS********/
/******************/
/******************/
StringName:: struct{
    data: [8]u8
}

/******************************/
/**********INITIALIZATION******/
/******************************/
initialize_gdexample_module :: proc "c" (p_userdata: rawptr, p_level:  GDE.InitializationLevel){
    if p_level != .INITIALIZATION_SCENE{
        return
    }
    context = runtime.default_context()

    class_name: StringName
    constructor.stringNameNewWithLatinChars(&class_name, "GDExample", false)
    parent_class_name: StringName
    constructor.stringNameNewWithLatinChars(&parent_class_name, "Sprite2D", false)

    class_info: GDE.GDExtensionClassCreationInfo2 = {
        is_virtual = false,
        is_abstract = false,
        is_exposed = true,
        //is_runtime = false,
        //icon_path = nil,
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
        get_virtual_call_data_func = nil,
        call_virtual_with_data_func = nil,
        class_userdata = nil,
    }

    api.classDBRegisterExtensionClass4(class_library, &class_name, &parent_class_name, &class_info)
    warning : GDE.GDExtensionInterfacePrintWarningWithMessage
    //warning("init message", "message", "init func", "this",  32, true)
    fmt.println("AAAAAAAAAaaaaaaahhhh", &class_library, &class_name, &parent_class_name, &class_info)
    gdexample_class_bind_method()

    destructors.stringNameDestructor(&class_name)
    destructors.stringNameDestructor(&parent_class_name)

}

deinitialize_gdexample_module :: proc "c" (p_userdata: rawptr, p_level: GDE.InitializationLevel){

}

//put GDE_Export somewhere??
//no? it's there just to add a visible true tag to the functions.
//Need to double check what is needed to make shared lib values visible. @extern?
//TODO: make extern?
@export
gdexample_library_init :: proc "contextless" (p_get_proc_address : GDE.InterfaceGetProcAddress, p_library: GDE.GDExtensionClassLibraryPtr, r_initialization: ^GDE.GDExtensionInitialization) -> b8 {
    context = runtime.default_context()
    class_library = p_library
    loadAPI(p_get_proc_address)


    /* This function will be called multiple times for each initialization level. */
    r_initialization.initialize   = initialize_gdexample_module
    r_initialization.deinitialize = deinitialize_gdexample_module
    r_initialization.userdata     = nil
    r_initialization.minimum_initialization_level = .INITIALIZATION_SCENE


    return true
}

gdexample_class_bind_method :: proc "c" (){

}

gdexampleClassCreateInstance :: proc "c" (p_class_user_data: rawptr) -> GDE.GDExtensionObjectPtr {
    context = runtime.default_context()

    fmt.println("2222222222")
    
    //create native Godot object.
    //Here we create an object that is part of Godot core library.
    class_name : StringName
    constructor.stringNameNewWithLatinChars(&class_name, "Sprite2D", false)
    object: GDE.GDExtensionObjectPtr = api.classdbConstructObject(&class_name)
    destructors.stringNameDestructor(&class_name)

    //Create extension object.
    self: ^GDExample = cast(^GDExample)api.mem_alloc(size_of(GDExample))
    class_constructor(self)
    self.object = object

    //Set extension instance in the native Godot object.
    constructor.stringNameNewWithLatinChars(&class_name, "GDExample", false)
    api.object_set_instance(object, &class_name, self)
    api.object_set_instance_binding(object, class_library, self, classBindingCallbacks)
    destructors.stringNameDestructor(&class_name)

    return object
}

gdexampleClassFreeInstance :: proc "c" (p_class_userdata: rawptr, p_instance: GDE.GDExtensionClassInstancePtr){
    context = runtime.default_context()
    if (p_instance == nil){
        return
    }
    self : ^GDExample = cast(^GDExample)p_instance
    class_destructor(self)
    api.mem_free(self)
}

//struct to hold node data
GDExample :: struct{
    object: GDE.GDExtensionObjectPtr, //stores the underlying Godot data
}



class_constructor :: proc(self: ^GDExample){

}
class_destructor  :: proc(self: ^GDExample){

}

//binding
class_bind_methods:: proc(){

}

classBindingCallbacks: GDE.GDExtensionInstanceBindingCallbacks = {
    create_callback    = nil,
    free_callback      = nil,
    reference_callback = nil
}

/**************************/
/******API WRAPPER*********/
/**************************/

/*
This file works as a collection of helpers to call the GDExtension API
in a less verbose way, as well as a cache for methods from the discovery API,
just so we don't have to keep loading the same methods again.
*/
class_library: GDE.GDExtensionClassLibraryPtr = nil

Constructors :: struct {
    stringNameNewWithLatinChars: GDE.GDExtensionInterfaceStringNameNewWithLatin1Chars,
}

constructor : Constructors

Destructors :: struct {
    stringNameDestructor: GDE.GDExtensionPtrDestructor
}

destructors: Destructors

API :: struct {
    classDBRegisterExtensionClass4: GDE.GDExtensionInterfaceClassdbRegisterExtensionClass2,
    classdbConstructObject: GDE.GDExtensionInterfaceClassdbConstructObject,
    object_set_instance: GDE.GDExtensionInterfaceObjectSetInstance,
    object_set_instance_binding: GDE.GDExtensionInterfaceObjectSetInstanceBinding,
    mem_alloc: GDE.GDExtensionInterfaceMemAlloc,
    mem_free: GDE.GDExtensionInterfaceMemFree,
}
api: API = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
}

loadAPI :: proc "c" (p_get_proc_address: GDE.InterfaceGetProcAddress){
    // Get helper functions first.
    variant_get_ptr_destructor: GDE.GDExtensionInterfaceVariantGetPtrDestructor  = cast(GDE.GDExtensionInterfaceVariantGetPtrDestructor)p_get_proc_address("variant_get_ptr_destructor")

    //constructors.
    constructor.stringNameNewWithLatinChars = cast(GDE.GDExtensionInterfaceStringNameNewWithLatin1Chars)p_get_proc_address("string_name_new_with_latin1_chars")

    //Destructors.
    destructors.stringNameDestructor = cast(GDE.GDExtensionPtrDestructor)variant_get_ptr_destructor(.GDEXTENSION_VARIANT_TYPE_STRING_NAME)

    //API.
    api.classDBRegisterExtensionClass4 = cast(GDE.GDExtensionInterfaceClassdbRegisterExtensionClass2)p_get_proc_address("classdb_register_extension_class2")
    api.classdbConstructObject = cast(GDE.GDExtensionInterfaceClassdbConstructObject)p_get_proc_address("classdb_construct_object")
    api.object_set_instance = cast(GDE.GDExtensionInterfaceObjectSetInstance)p_get_proc_address("object_set_instance")
    api.object_set_instance_binding = cast(GDE.GDExtensionInterfaceObjectSetInstanceBinding)p_get_proc_address("object_set_instance_binding")
    api.mem_alloc = cast(GDE.GDExtensionInterfaceMemAlloc)p_get_proc_address("mem_alloc")
    api.mem_free = cast(GDE.GDExtensionInterfaceMemFree)p_get_proc_address("mem_free")
}

