package gdextension


/* VARIANT TYPES */

GDExtensionVariantType ::  enum {
	GDEXTENSION_VARIANT_TYPE_NIL,

	/*  atomic types */
	GDEXTENSION_VARIANT_TYPE_BOOL,
	GDEXTENSION_VARIANT_TYPE_INT,
	GDEXTENSION_VARIANT_TYPE_FLOAT,
	GDEXTENSION_VARIANT_TYPE_STRING,

	/* math types */
	GDEXTENSION_VARIANT_TYPE_VECTOR2,
	GDEXTENSION_VARIANT_TYPE_VECTOR2I,
	GDEXTENSION_VARIANT_TYPE_RECT2,
	GDEXTENSION_VARIANT_TYPE_RECT2I,
	GDEXTENSION_VARIANT_TYPE_VECTOR3,
	GDEXTENSION_VARIANT_TYPE_VECTOR3I,
	GDEXTENSION_VARIANT_TYPE_TRANSFORM2D,
	GDEXTENSION_VARIANT_TYPE_VECTOR4,
	GDEXTENSION_VARIANT_TYPE_VECTOR4I,
	GDEXTENSION_VARIANT_TYPE_PLANE,
	GDEXTENSION_VARIANT_TYPE_QUATERNION,
	GDEXTENSION_VARIANT_TYPE_AABB,
	GDEXTENSION_VARIANT_TYPE_BASIS,
	GDEXTENSION_VARIANT_TYPE_TRANSFORM3D,
	GDEXTENSION_VARIANT_TYPE_PROJECTION,

	/* misc types */
	GDEXTENSION_VARIANT_TYPE_COLOR,
	GDEXTENSION_VARIANT_TYPE_STRING_NAME,
	GDEXTENSION_VARIANT_TYPE_NODE_PATH,
	GDEXTENSION_VARIANT_TYPE_RID,
	GDEXTENSION_VARIANT_TYPE_OBJECT,
	GDEXTENSION_VARIANT_TYPE_CALLABLE,
	GDEXTENSION_VARIANT_TYPE_SIGNAL,
	GDEXTENSION_VARIANT_TYPE_DICTIONARY,
	GDEXTENSION_VARIANT_TYPE_ARRAY,

	/* typed arrays */
	GDEXTENSION_VARIANT_TYPE_PACKED_BYTE_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_INT32_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_INT64_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT32_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT64_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_STRING_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR2_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR3_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_COLOR_ARRAY,
	GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR4_ARRAY,

	GDEXTENSION_VARIANT_TYPE_VARIANT_MAX
} 

//GDExtensionVariantType: VariantType

GDExtensionVariantPtr ::                 rawptr       
GDExtensionConstVariantPtr ::            rawptr 
GDExtensionUninitializedVariantPtr ::    rawptr       
GDExtensionStringNamePtr ::              rawptr       
GDExtensionConstStringNamePtr ::         rawptr 
GDExtensionUninitializedStringNamePtr :: rawptr       
GDExtensionStringPtr ::                  rawptr
GDExtensionConstStringPtr ::             rawptr
GDExtensionUninitializedStringPtr ::     rawptr
GDExtensionObjectPtr ::                  rawptr
GDExtensionConstObjectPtr ::             rawptr
GDExtensionUninitializedObjectPtr ::     rawptr
GDExtensionTypePtr ::                    rawptr
GDExtensionConstTypePtr ::               rawptr 
GDExtensionUninitializedTypePtr ::       rawptr
GDExtensionMethodBindPtr ::              rawptr
GDExtensionInt ::                        i64    
GDObjectInstanceID ::                    u64  
GDExtensionBool  ::                      b8 
GDExtensionRefPtr ::                     rawptr
GDExtensionConstRefPtr ::                rawptr 
GDExtensionClassLibraryPtr  :: rawptr

InitializationLevel ::enum{
	INITIALIZATION_CORE,
	INITIALIZATION_SERVERS,
	INITIALIZATION_SCENE,
	INITIALIZATION_EDITOR,
	MAX_INITIALIZATION_LEVEL,
}


GDExtensionClassCreationInfo4 :: struct {
	is_virtual:            GDExtensionBool,
	is_abstract:           GDExtensionBool,
	is_exposed:            GDExtensionBool,
	is_runtime:            GDExtensionBool,
	icon_path:             GDExtensionConstStringPtr,
	set_func :             GDExtensionClassSet,
	get_func :             GDExtensionClassGet,
	get_property_list_func:GDExtensionClassGetPropertyList,
	free_property_list_func: GDExtensionClassFreePropertyList2,
	property_can_revert_func: GDExtensionClassPropertyCanRevert,
	property_get_revert_func: GDExtensionClassPropertyGetRevert,
	validate_property_func:GDExtensionClassValidateProperty,
	notification_func:     GDExtensionClassNotification2,
	to_string_func:        GDExtensionClassToString,
	reference_func:        GDExtensionClassReference,
	unreference_func:      GDExtensionClassUnreference,
	create_instance_func:  GDExtensionClassCreateInstance2, // (Default) constructor; mandatory. If the class is not instantiable, consider making it virtual or abstract.
	free_instance_func:    GDExtensionClassFreeInstance, // Destructor; mandatory.
	recreate_instance_func:GDExtensionClassRecreateInstance,
	// Queries a virtual function by name and returns a callback to invoke the requested virtual function.
	get_virtual_func:      GDExtensionClassGetVirtual2,
	// Paired with `call_virtual_with_data_func`, this is an alternative to `get_virtual_func` for extensions that
	// need or benefit from extra data when calling virtual functions.
	// Returns user data that will be passed to `call_virtual_with_data_func`.
	// Returning `NULL` from this function signals to Godot that the virtual function is not overridden.
	// Data returned from this function should be managed by the extension and must be valid until the extension is deinitialized.
	// You should supply either `get_virtual_func`, or `get_virtual_call_data_func` with `call_virtual_with_data_func`.
	get_virtual_call_data_func:GDExtensionClassGetVirtualCallData2,
	// Used to call virtual functions when `get_virtual_call_data_func` is not null.
	call_virtual_with_data_func:GDExtensionClassCallVirtualWithData,
	class_userdata: rawptr, // Per-class user data, later accessible in instance bindings.
} 


GDExtensionInstanceBindingCallbacks :: struct {
	create_callback: GDExtensionInstanceBindingCreateCallback,
	free_callback: GDExtensionInstanceBindingFreeCallback,
	 reference_callback: GDExtensionInstanceBindingReferenceCallback,
}

GDExtensionInstanceBindingCreateCallback :: proc(p_token: rawptr, p_instance: rawptr) -> rawptr;
GDExtensionInstanceBindingFreeCallback :: proc(p_token: rawptr, p_instance: rawptr, p_binding: rawptr);
GDExtensionInstanceBindingReferenceCallback :: proc(p_token: rawptr, p_binding: rawptr, p_reference: GDExtensionBool) -> GDExtensionBool;


/* EXTENSION CLASSES */

GDExtensionClassInstancePtr :: rawptr;

GDExtensionClassSet ::    proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr,  p_value: GDExtensionConstVariantPtr) -> GDExtensionBool
GDExtensionClassGet ::    proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr,  r_ret: GDExtensionVariantPtr) -> GDExtensionBool
GDExtensionClassGetRID :: proc "c" ( p_instance: GDExtensionClassInstancePtr) -> u64

GDExtensionClassGetPropertyList ::       proc "c" ( p_instance: GDExtensionClassInstancePtr, r_count: ^ i32) -> ^GDExtensionPropertyInfo;
GDExtensionClassFreePropertyList ::      proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_list: ^GDExtensionPropertyInfo);
GDExtensionClassFreePropertyList2 ::     proc "c" ( p_instance: GDExtensionClassInstancePtr, p_list: ^GDExtensionPropertyInfo , p_count: u32);
GDExtensionClassPropertyCanRevert ::     proc "c" (p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr) -> GDExtensionBool
GDExtensionClassPropertyGetRevert ::     proc "c" (p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr,  r_ret: GDExtensionVariantPtr) -> GDExtensionBool
GDExtensionClassValidateProperty ::      proc "c" (p_instance: GDExtensionClassInstancePtr,  p_property: ^GDExtensionPropertyInfo) -> GDExtensionBool
GDExtensionClassNotification ::          proc "c" ( p_instance:GDExtensionClassInstancePtr,  p_what: i32); // Deprecated. Use GDExtensionClassNotification2 instead.
GDExtensionClassNotification2 ::         proc "c" ( p_instance:GDExtensionClassInstancePtr, p_what: i32,  p_reversed: GDExtensionBool);
GDExtensionClassToString ::              proc "c" ( p_instance:GDExtensionClassInstancePtr, r_is_valid: GDExtensionBool, p_out: GDExtensionStringPtr);
GDExtensionClassReference ::             proc "c" ( p_instance:GDExtensionClassInstancePtr);
GDExtensionClassUnreference ::           proc "c" ( p_instance:GDExtensionClassInstancePtr);
GDExtensionClassCallVirtual ::           proc "c" ( p_instance:GDExtensionClassInstancePtr, p_args: GDExtensionConstTypePtr ,  r_ret: GDExtensionTypePtr);
GDExtensionClassCreateInstance ::        proc "c" ( p_class_userdata: rawptr) -> GDExtensionObjectPtr;
GDExtensionClassCreateInstance2 ::       proc "c" (p_class_userdata: rawptr, p_notify_postinitialize: GDExtensionBool) -> GDExtensionObjectPtr;
GDExtensionClassFreeInstance ::          proc "c" (p_class_userdata: rawptr, p_instance: GDExtensionClassInstancePtr);
GDExtensionClassRecreateInstance ::      proc "c" (p_class_userdata: rawptr, p_object: GDExtensionObjectPtr) -> GDExtensionClassInstancePtr;
GDExtensionClassGetVirtual ::            proc "c" (p_class_userdata: rawptr, p_name: GDExtensionConstStringNamePtr) -> GDExtensionClassCallVirtual;
GDExtensionClassGetVirtual2 ::           proc "c" (p_class_userdata: rawptr, p_name: GDExtensionConstStringNamePtr, p_hash: u32) -> GDExtensionClassCallVirtual;
GDExtensionClassGetVirtualCallData ::    proc "c" (p_class_userdata: rawptr,  p_name: GDExtensionConstStringNamePtr) -> rawptr;
GDExtensionClassGetVirtualCallData2 ::   proc "c" (p_class_userdata: rawptr,  p_name: GDExtensionConstStringNamePtr, p_hash: u32) -> rawptr;
GDExtensionClassCallVirtualWithData  ::  proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr, p_virtual_call_userdata: rawptr,  p_args: ^GDExtensionConstTypePtr, r_ret: GDExtensionTypePtr);



GDExtensionPropertyInfo  :: struct {
	type:       GDExtensionVariantType,
	name:       GDExtensionStringNamePtr,
	class_name: GDExtensionStringNamePtr,
	hint:       u32, // Bitfield of `PropertyHint` (defined in `extension_api.json`).
	hint_string:GDExtensionStringPtr,
	usage:      u32, // Bitfield of `PropertyUsageFlags` (defined in `extension_api.json`).
}

//GDExtensionPropertyInfo : PropertyInfo


/*typedef struct {
	GDExtensionStringNamePtr name;
	void *method_userdata;
	GDExtensionClassMethodCall call_func;
	GDExtensionClassMethodPtrCall ptrcall_func;
	uint32_t method_flags; // Bitfield of `GDExtensionClassMethodFlags`.

	/* If `has_return_value` is false, `return_value_info` and `return_value_metadata` are ignored.
	 *
	 * @todo Consider dropping `has_return_value` and making the other two properties match `GDExtensionMethodInfo` and `GDExtensionClassVirtualMethod` for consistency in future version of this struct.
	 */
	GDExtensionBool has_return_value;
	GDExtensionPropertyInfo *return_value_info;
	GDExtensionClassMethodArgumentMetadata return_value_metadata;

	/* Arguments: `arguments_info` and `arguments_metadata` are array of size `argument_count`.
	 * Name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies.
	 *
	 * @todo Consider renaming `arguments_info` to `arguments` for consistency in future version of this struct.
	 */
	uint32_t argument_count;
	GDExtensionPropertyInfo *arguments_info;
	GDExtensionClassMethodArgumentMetadata *arguments_metadata;

	/* Default arguments: `default_arguments` is an array of size `default_argument_count`. */
	uint32_t default_argument_count;
	GDExtensionVariantPtr *default_arguments;
} GDExtensionClassMethodInfo;

typedef struct {
	GDExtensionStringNamePtr name;
	uint32_t method_flags; // Bitfield of `GDExtensionClassMethodFlags`.

	GDExtensionPropertyInfo return_value;
	GDExtensionClassMethodArgumentMetadata return_value_metadata;

	uint32_t argument_count;
	GDExtensionPropertyInfo *arguments;
	GDExtensionClassMethodArgumentMetadata *arguments_metadata;
} GDExtensionClassVirtualMethodInfo;*/


GDExtensionInitialization :: struct {
	    /* Minimum initialization level required.
	     * If Core or Servers, the extension needs editor or game restart to take effect */
	minimum_initialization_level: InitializationLevel,
	    /* Up to the user to supply when initializing */
	userdata: rawptr,
	    /* This function will be called multiple times for each initialization level. */
	initialize:   proc "c" (userdata: rawptr, p_level: InitializationLevel),
	deinitialize: proc "c" (userdata: rawptr, p_level: InitializationLevel),
}

//GDExtensionInterfaceFunctionPtr  :: ^proc
InterfaceGetProcAddress :: #type proc "c" (function_name: cstring) -> rawptr
//GDExtensionObjectPtr (*GDExtensionInterfaceGlobalGetSingleton)(GDExtensionConstStringNamePtr p_name);

GDExtensionInterfaceGlobalGetSingleton :: proc "c" (p_name: GDExtensionConstStringNamePtr) -> GDExtensionObjectPtr



//typedef void (*GDExtensionInterfaceStringNameNewWithLatin1Chars)(GDExtensionUninitializedStringNamePtr r_dest, const char *p_contents, GDExtensionBool p_is_static);
GDExtensionInterfaceStringNameNewWithLatin1Chars :: proc "c" (r_dest: GDExtensionUninitializedStringNamePtr, p_contents: cstring, p_is_static: GDExtensionBool)

//GDExtensionInterfaceClassdbRegisterExtensionClass2 :: proc "c" ( p_library: GDExtensionClassLibraryPtr,  p_class_name: GDExtensionConstStringNamePtr,  p_parent_class_name:GDExtensionConstStringNamePtr, p_extension_funcs:GDExtensionClassCreationInfo2)
GDExtensionInterfaceClassdbRegisterExtensionClass4 :: proc "c" ( p_library:GDExtensionClassLibraryPtr,  p_class_name:GDExtensionConstStringNamePtr,  p_parent_class_name:GDExtensionConstStringNamePtr, p_extension_funcs: ^GDExtensionClassCreationInfo4);

GDExtensionPtrDestructor :: proc "c" (p_base: GDExtensionTypePtr)


/**
 * @name variant_get_ptr_destructor
 * @since 4.1
 *
 * Gets a pointer to a function than can call the destructor for a type of Variant.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function than can call the destructor for a type of Variant.
 */
GDExtensionInterfaceVariantGetPtrDestructor :: proc "c" (p_type: GDExtensionVariantType) -> GDExtensionPtrDestructor;


/**
 * @name classdb_construct_object
 * @since 4.1
 * @deprecated in Godot 4.4. Use `classdb_construct_object2` instead.
 *
 * Constructs an Object of the requested class.
 *
 * The passed class must be a built-in godot class, or an already-registered extension class. In both cases, object_set_instance() should be called to fully initialize the object.
 *
 * @param p_classname A pointer to a StringName with the class name.
 *
 * @return A pointer to the newly created Object.
 */
GDExtensionInterfaceClassdbConstructObject :: proc(p_classname: GDExtensionConstStringNamePtr) -> GDExtensionObjectPtr

/**
 * @name classdb_construct_object2
 * @since 4.4
 *
 * Constructs an Object of the requested class.
 *
 * The passed class must be a built-in godot class, or an already-registered extension class. In both cases, object_set_instance() should be called to fully initialize the object.
 *
 * "NOTIFICATION_POSTINITIALIZE" must be sent after construction.
 *
 * @param p_classname A pointer to a StringName with the class name.
 *
 * @return A pointer to the newly created Object.
 */
GDExtensionInterfaceClassdbConstructObject2 :: proc(p_classname: GDExtensionConstStringNamePtr) -> GDExtensionObjectPtr


/**
 * @name object_set_instance
 * @since 4.1
 *
 * Sets an extension class instance on a Object.
 *
 * @param p_o A pointer to the Object.
 * @param p_classname A pointer to a StringName with the registered extension class's name.
 * @param p_instance A pointer to the extension class instance.
 */
GDExtensionInterfaceObjectSetInstance :: proc( p_o: GDExtensionObjectPtr, p_classname: GDExtensionConstStringNamePtr, p_instance: GDExtensionClassInstancePtr); /* p_classname should be a registered extension class and should extend the p_o object's class. */


/**
 * @name object_set_instance_binding
 * @since 4.1
 *
 * Sets an Object's instance binding.
 *
 * @param p_o A pointer to the Object.
 * @param p_library A token the library received by the GDExtension's entry point function.
 * @param p_binding A pointer to the instance binding.
 * @param p_callbacks A pointer to a GDExtensionInstanceBindingCallbacks struct.
 */
GDExtensionInterfaceObjectSetInstanceBinding :: proc(p_o: GDExtensionObjectPtr, p_token: rawptr, p_binding: rawptr, p_callbacks: GDExtensionInstanceBindingCallbacks);


/* INTERFACE: Memory */

//TODO: adapt to Odin memory management. Arena, custom allocator etc.
/**
 * @name mem_alloc
 * @since 4.1
 *
 * Allocates memory.
 *
 * @param p_bytes The amount of memory to allocate in bytes.
 *
 * @return A pointer to the allocated memory, or NULL if unsuccessful.
 */
GDExtensionInterfaceMemAlloc :: proc(p_bytes: uint) -> rawptr;

/**
 * @name mem_realloc
 * @since 4.1
 *
 * Reallocates memory.
 *
 * @param p_ptr A pointer to the previously allocated memory.
 * @param p_bytes The number of bytes to resize the memory block to.
 *
 * @return A pointer to the allocated memory, or NULL if unsuccessful.
 */
GDExtensionInterfaceMemRealloc :: proc(p_ptr: rawptr, p_bytes: uint) -> rawptr;

/**
 * @name mem_free
 * @since 4.1
 *
 * Frees memory.
 *
 * @param p_ptr A pointer to the previously allocated memory.
 */
GDExtensionInterfaceMemFree :: proc(p_ptr: rawptr);