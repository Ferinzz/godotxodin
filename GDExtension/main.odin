package main

import "base:runtime"
import "core:fmt"
import str "core:strings"
import "core:slice"
import strc "core:strconv"
import GDE "gdextension"

main :: proc() {
    fmt.println("CORE")
}


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
initialize_gdexample_module   :: proc "c" (p_userdata: rawptr, p_level:  GDE.InitializationLevel){
    if p_level != .INITIALIZATION_SCENE{
        return
    }

    class_name: StringName
    constructor.stringNameNewWithLatinChars(&class_name, "GDExample", false)
    parent_class_name: StringName
    constructor.stringNameNewWithLatinChars(&parent_class_name, "Sprite2D", false)

    class_info: GDE.GDExtensionClassCreationInfo4 = {
        is_virtual = false,
        is_abstract = false,
        is_exposed = true,
        is_runtime = true,
        icon_path = nil,
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
        create_instance_func = nil,//gdexample_class_create_instance,
        free_instance_func = nil  ,//gdexample_class_free_instance,
        recreate_instance_func = nil,
        get_virtual_func = nil,
        get_virtual_call_data_func = nil,
        call_virtual_with_data_func = nil,
        class_userdata = nil,
    }

    api.classDBRegisterExtensionClass4(class_library, &class_name, &parent_class_name, &class_info)

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
gdexample_library_init :: proc "c" (p_get_proc_address : GDE.InterfaceGetProcAddress, p_library: GDE.GDExtensionClassLibraryPtr, r_initialization: ^GDE.GDExtensionInitialization) -> b8 {
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

gdexampleClassCreateInstance :: proc(p_class_user_data: rawptr) -> GDE.GDExtensionObjectPtr {
    ptr: GDE.GDExtensionObjectPtr = nil
    return ptr
}

gdexampleClassFreeInstance :: proc(p_class_userdata: rawptr, p_instance: GDE.GDExtensionClassInstancePtr){

}

//struct to hold node data
classData:: struct{
    object: GDE.GDExtensionObjectPtr, //stores the underlying Godot data
}

GDExample : classData

class_constructor :: proc(self: ^classData){

}
class_destructor  :: proc(self: ^classData){

}

//binding
class_bind_methods:: proc(){

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
    classDBRegisterExtensionClass4: GDE.GDExtensionInterfaceClassdbRegisterExtensionClass4,
    classdbConstructObject: GDE.GDExtensionInterfaceClassdbConstructObject,
    object_set_instance: GDE.GDExtensionInterfaceObjectSetInstance,
    object_set_instance_binding: GDE.GDExtensionInterfaceObjectSetInstanceBinding,
    mem_alloc: GDE.GDExtensionInterfaceMemAlloc,
    mem_free: GDE.GDExtensionInterfaceMemFree,
}
api: API

loadAPI :: proc(p_get_proc_address: GDE.InterfaceGetProcAddress){
    // Get helper functions first.
    variant_get_ptr_destructor: GDE.GDExtensionInterfaceVariantGetPtrDestructor  = cast(GDE.GDExtensionInterfaceVariantGetPtrDestructor)p_get_proc_address("variant_get_ptr_destructor")

    //API.
    api.classDBRegisterExtensionClass4 = cast(GDE.GDExtensionInterfaceClassdbRegisterExtensionClass4)p_get_proc_address("classdb_register_extension_class2")
    api.classdbConstructObject = cast(GDE.GDExtensionInterfaceClassdbConstructObject)p_get_proc_address("classdb_construct_object")
    api.object_set_instance = cast(GDE.GDExtensionInterfaceObjectSetInstance)p_get_proc_address("object_set_instance")
    api.object_set_instance_binding = cast(GDE.GDExtensionInterfaceObjectSetInstanceBinding)p_get_proc_address("object_set_instance_binding")
    api.mem_alloc = cast(GDE.GDExtensionInterfaceMemAlloc)p_get_proc_address("mem_alloc")
    api.mem_free = cast(GDE.GDExtensionInterfaceMemFree)p_get_proc_address("mem_free")

    //constructors.
    constructor.stringNameNewWithLatinChars = cast(GDE.GDExtensionInterfaceStringNameNewWithLatin1Chars)p_get_proc_address("string_name_with_latin1_chars")

    //Destructors.
    destructors.stringNameDestructor = cast(GDE.GDExtensionPtrDestructor)variant_get_ptr_destructor(.GDEXTENSION_VARIANT_TYPE_STRING_NAME)
}

