package gdextension


import "core:c"

/* VARIANT TYPES */

GDExtensionVariantType ::  enum {
	NIL,

	/*  atomic types */
	BOOL,
	INT,
	FLOAT,
	STRING,

	/* math types */
	VECTOR2,
	VECTOR2I,
	RECT2,
	RECT2I,
	VECTOR3,
	VECTOR3I,
	TRANSFORM2D,
	VECTOR4,
	VECTOR4I,
	PLANE,
	QUATERNION,
	AABB,
	BASIS,
	TRANSFORM3D,
	PROJECTION,

	/* misc types */
	COLOR,
	STRING_NAME,
	NODE_PATH,
	RID,
	OBJECT,
	CALLABLE,
	SIGNAL,
	DICTIONARY,
	ARRAY,

	/* typed arrays */
	PACKED_BYTE_ARRAY,
	PACKED_INT32_ARRAY,
	PACKED_INT64_ARRAY,
	PACKED_FLOAT32_ARRAY,
	PACKED_FLOAT64_ARRAY,
	PACKED_STRING_ARRAY,
	PACKED_VECTOR2_ARRAY,
	PACKED_VECTOR3_ARRAY,
	PACKED_COLOR_ARRAY,
	PACKED_VECTOR4_ARRAY,

	VARIANT_MAX
} 

GDExtensionVariantOperator :: enum {
	/* comparison */
	VARIANT_OP_EQUAL,
	VARIANT_OP_NOT_EQUAL,
	VARIANT_OP_LESS,
	VARIANT_OP_LESS_EQUAL,
	VARIANT_OP_GREATER,
	VARIANT_OP_GREATER_EQUAL,

	/* mathematic */
	VARIANT_OP_ADD,
	VARIANT_OP_SUBTRACT,
	VARIANT_OP_MULTIPLY,
	VARIANT_OP_DIVIDE,
	VARIANT_OP_NEGATE,
	VARIANT_OP_POSITIVE,
	VARIANT_OP_MODULE,
	VARIANT_OP_POWER,

	/* bitwise */
	VARIANT_OP_SHIFT_LEFT,
	VARIANT_OP_SHIFT_RIGHT,
	VARIANT_OP_BIT_AND,
	VARIANT_OP_BIT_OR,
	VARIANT_OP_BIT_XOR,
	VARIANT_OP_BIT_NEGATE,

	/* logic */
	VARIANT_OP_AND,
	VARIANT_OP_OR,
	VARIANT_OP_XOR,
	VARIANT_OP_NOT,

	/* containment */
	VARIANT_OP_IN,
	VARIANT_OP_MAX

}

//GDExtensionVariantType: VariantType
//use as markers to know what type to expect.

GDExtensionVariantPtr 							:: rawptr       
GDExtensionConstVariantPtr 						:: rawptr 
GDExtensionConstVariantPtrargs 					:: [^]rawptr 
GDExtensionUninitializedVariantPtr 				:: rawptr       
GDExtensionStringNamePtr 						:: rawptr       
GDExtensionConstStringNamePtr 					:: rawptr 
GDExtensionUninitializedStringNamePtr          	:: rawptr       
GDExtensionStringPtr 							:: rawptr
GDExtensionConstStringPtr 						:: rawptr
GDExtensionUninitializedStringPtr 				:: rawptr
GDExtensionObjectPtr 							:: rawptr
GDExtensionConstObjectPtr 						:: rawptr
GDExtensionUninitializedObjectPtr 				:: rawptr
GDExtensionTypePtr 								:: rawptr
GDExtensionConstTypePtr 						:: rawptr 
GDExtensionUninitializedTypePtr 				:: rawptr
GDExtensionMethodBindPtr 						:: rawptr
GDExtensionInt 									:: int    
GDObjectInstanceID 								:: u64  
GDExtensionBool  								:: b8 
GDExtensionRefPtr 								:: rawptr
GDExtensionConstRefPtr 							:: rawptr 
GDExtensionClassLibraryPtr  					:: rawptr
GDExtensionConstTypePtrargs						:: [^]rawptr

InitializationLevel :: enum {
	INITIALIZATION_CORE,
	INITIALIZATION_SERVERS,
	INITIALIZATION_SCENE,
	INITIALIZATION_EDITOR,
	MAX_INITIALIZATION_LEVEL,
}

/* VARIANT DATA I/O */

GDExtensionCallErrorType :: enum {
	GDEXTENSION_CALL_OK,
	GDEXTENSION_CALL_ERROR_INVALID_METHOD,
	GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT, // Expected a different variant type.
	GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS, // Expected lower number of arguments.
	GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS, // Expected higher number of arguments.
	GDEXTENSION_CALL_ERROR_INSTANCE_IS_NULL,
	GDEXTENSION_CALL_ERROR_METHOD_NOT_CONST, // Used for const call.
}

GDExtensionCallError :: struct {
	error: GDExtensionCallErrorType,
	argument: i32,
	expected: i32,
}

GDExtensionVariantFromTypeConstructorFunc	:: proc(GDExtensionUninitializedVariantPtr, GDExtensionTypePtr);
GDExtensionTypeFromVariantConstructorFunc	:: proc(GDExtensionUninitializedTypePtr, GDExtensionVariantPtr);
GDExtensionVariantGetInternalPtrFunc 		:: proc(GDExtensionVariantPtr) -> rawptr;
GDExtensionPtrOperatorEvaluator 			:: proc(p_left: GDExtensionConstTypePtr, 		 p_right: GDExtensionConstTypePtr, 	  r_result: GDExtensionTypePtr);
GDExtensionPtrBuiltInMethod 				:: proc(p_base: GDExtensionTypePtr, 			 p_args: GDExtensionConstTypePtrargs, r_return:  GDExtensionTypePtr, p_argument_count: i64);
GDExtensionPtrConstructor 					:: proc(p_base: GDExtensionUninitializedTypePtr, p_args: GDExtensionConstTypePtrargs);
GDExtensionPtrDestructor 					:: proc(p_base: GDExtensionTypePtr);
GDExtensionPtrSetter 						:: proc(p_base: GDExtensionTypePtr, 	 p_value: GDExtensionConstTypePtr);
GDExtensionPtrGetter 						:: proc(p_base: GDExtensionConstTypePtr, r_value:  GDExtensionTypePtr);
GDExtensionPtrIndexedSetter 				:: proc(p_base: GDExtensionTypePtr, 	 p_index: GDExtensionInt, 		  p_value: GDExtensionConstTypePtr);
GDExtensionPtrIndexedGetter 				:: proc(p_base: GDExtensionConstTypePtr, p_index:  GDExtensionInt, 		  r_value: GDExtensionTypePtr);
GDExtensionPtrKeyedSetter 					:: proc(p_base: GDExtensionTypePtr, 	 p_key: GDExtensionConstTypePtr,  p_value: GDExtensionConstTypePtr);
GDExtensionPtrKeyedGetter 					:: proc(p_base: GDExtensionConstTypePtr, p_key:  GDExtensionConstTypePtr, r_value: GDExtensionTypePtr);
GDExtensionPtrKeyedChecker 					:: proc(p_base: GDExtensionConstVariantPtr, p_key:  GDExtensionConstVariantPtr) -> u32;
GDExtensionPtrUtilityFunction 				:: proc(r_return: GDExtensionTypePtr,    p_args: GDExtensionConstTypePtrargs, p_argument_count: i64);


GDExtensionClassCreationInfo2 :: struct {
	is_virtual: GDExtensionBool,
	is_abstract: GDExtensionBool,
	is_exposed: GDExtensionBool,
	set_func: GDExtensionClassSet,
	get_func: GDExtensionClassGet,
	get_property_list_func: GDExtensionClassGetPropertyList,
	free_property_list_func: GDExtensionClassFreePropertyList,
	property_can_revert_func: GDExtensionClassPropertyCanRevert,
	property_get_revert_func: GDExtensionClassPropertyGetRevert,
	validate_property_func: GDExtensionClassValidateProperty,
	notification_func: GDExtensionClassNotification2,
	to_string_func: GDExtensionClassToString,
	reference_func: GDExtensionClassReference,
	unreference_func: GDExtensionClassUnreference,
	create_instance_func: GDExtensionClassCreateInstance, // (Default) constructor; mandatory. If the class is not instantiable, consider making it virtual or abstract,
	free_instance_func: GDExtensionClassFreeInstance, // Destructor; mandatory,
	recreate_instance_func: GDExtensionClassRecreateInstance,
	// Queries a virtual function by name and returns a callback to invoke the requested virtual function.
	 get_virtual_func: GDExtensionClassGetVirtual,
	// Paired with `call_virtual_with_data_func`, this is an alternative to `get_virtual_func` for extensions that
	// need or benefit from extra data when calling virtual functions.
	// Returns user data that will be passed to `call_virtual_with_data_func`.
	// Returning `NULL` from this function signals to Godot that the virtual function is not overridden.
	// Data returned from this function should be managed by the extension and must be valid until the extension is deinitialized.
	// You should supply either `get_virtual_func`, or `get_virtual_call_data_func` with `call_virtual_with_data_func`.
	 get_virtual_call_data_func: GDExtensionClassGetVirtualCallData,
	// Used to call virtual functions when `get_virtual_call_data_func` is not null.
	 call_virtual_with_data_func: GDExtensionClassCallVirtualWithData,
	get_rid_func: GDExtensionClassGetRID,
	class_userdata: rawptr, // Per-class user data, later accessible in instance bindings.
} ; // Deprecated. Use GDExtensionClassCreationInfo4 instead.

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
	create_callback: 	 GDExtensionInstanceBindingCreateCallback,
	free_callback: 		 GDExtensionInstanceBindingFreeCallback,
	 reference_callback: GDExtensionInstanceBindingReferenceCallback,
}

GDExtensionInstanceBindingCreateCallback 	:: proc(p_token: rawptr, p_instance: rawptr) -> rawptr;
GDExtensionInstanceBindingFreeCallback 		:: proc(p_token: rawptr, p_instance: rawptr, p_binding: rawptr);
GDExtensionInstanceBindingReferenceCallback :: proc(p_token: rawptr, p_binding: rawptr, p_reference: GDExtensionBool) -> GDExtensionBool;


/* EXTENSION CLASSES */

GDExtensionClassInstancePtr :: rawptr;

GDExtensionClassSet 	::proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr,  p_value: GDExtensionConstVariantPtr) -> GDExtensionBool
GDExtensionClassGet 	::proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr,  r_ret: GDExtensionVariantPtr) -> GDExtensionBool
GDExtensionClassGetRID  :: proc "c" ( p_instance: GDExtensionClassInstancePtr) -> u64

GDExtensionClassGetPropertyList 		:: proc "c" ( p_instance: GDExtensionClassInstancePtr, r_count: ^u32) -> ^GDExtensionPropertyInfo;
GDExtensionClassFreePropertyList 		:: proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_list: ^GDExtensionPropertyInfo);
GDExtensionClassFreePropertyList2 		:: proc "c" ( p_instance: GDExtensionClassInstancePtr, p_list: ^GDExtensionPropertyInfo , p_count: u32);
GDExtensionClassPropertyCanRevert 		:: proc "c" (p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr) -> GDExtensionBool
GDExtensionClassPropertyGetRevert 		:: proc "c" (p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr,  r_ret: GDExtensionVariantPtr) -> GDExtensionBool
GDExtensionClassValidateProperty 		:: proc "c" (p_instance: GDExtensionClassInstancePtr,  p_property: ^GDExtensionPropertyInfo) -> GDExtensionBool
GDExtensionClassNotification 			:: proc "c" ( p_instance:GDExtensionClassInstancePtr,  p_what: i32); // Deprecated. Use GDExtensionClassNotification2 instead.
GDExtensionClassNotification2 			:: proc "c" ( p_instance:GDExtensionClassInstancePtr, p_what: i32,  p_reversed: GDExtensionBool);
GDExtensionClassToString 				:: proc "c" ( p_instance:GDExtensionClassInstancePtr, r_is_valid: GDExtensionBool, p_out: GDExtensionStringPtr);
GDExtensionClassReference 				:: proc "c" ( p_instance:GDExtensionClassInstancePtr);
GDExtensionClassUnreference 			:: proc "c" ( p_instance:GDExtensionClassInstancePtr);
GDExtensionClassCallVirtual 			:: proc "c" ( p_instance:GDExtensionClassInstancePtr, p_args: GDExtensionConstTypePtr ,  r_ret: GDExtensionTypePtr);
GDExtensionClassCreateInstance 			:: proc "c" ( p_class_userdata: rawptr) -> GDExtensionObjectPtr;
GDExtensionClassCreateInstance2 		:: proc "c" (p_class_userdata: rawptr, p_notify_postinitialize: GDExtensionBool) -> GDExtensionObjectPtr;
GDExtensionClassFreeInstance 			:: proc "c" (p_class_userdata: rawptr, p_instance: GDExtensionClassInstancePtr);
GDExtensionClassRecreateInstance 		:: proc "c" (p_class_userdata: rawptr, p_object: GDExtensionObjectPtr) -> GDExtensionClassInstancePtr;
GDExtensionClassGetVirtual 				:: proc "c" (p_class_userdata: rawptr, p_name: GDExtensionConstStringNamePtr) -> GDExtensionClassCallVirtual;
GDExtensionClassGetVirtual2 			:: proc "c" (p_class_userdata: rawptr, p_name: GDExtensionConstStringNamePtr, p_hash: u32) -> GDExtensionClassCallVirtual;
GDExtensionClassGetVirtualCallData 		:: proc "c" (p_class_userdata: rawptr,  p_name: GDExtensionConstStringNamePtr) -> rawptr;
GDExtensionClassGetVirtualCallData2 	:: proc "c" (p_class_userdata: rawptr,  p_name: GDExtensionConstStringNamePtr, p_hash: u32) -> rawptr;
GDExtensionClassCallVirtualWithData  	:: proc "c" ( p_instance: GDExtensionClassInstancePtr,  p_name: GDExtensionConstStringNamePtr, p_virtual_call_userdata: rawptr,  p_args: GDExtensionConstTypePtrargs, r_ret: GDExtensionTypePtr);



GDExtensionPropertyInfo  :: struct {
	type:       GDExtensionVariantType,
	name:       GDExtensionStringNamePtr,
	class_name: GDExtensionStringNamePtr,
	hint:       u32, // Bitfield of `PropertyHint` (defined in `extension_api.json`).
	hint_string:GDExtensionStringPtr,
	usage:      u32, // Bitfield of `PropertyUsageFlags` (defined in `extension_api.json`).
}


/* Method */

GDExtensionClassMethodFlags :: enum {
	NORMAL = 1,
	EDITOR = 2,
	CONST = 4,
	VIRTUAL = 8,
	VARARG = 16,
	STATIC = 32,
	DEFAULT = NORMAL,
}

GDExtensionClassMethodArgumentMetadata :: enum c.int {
	NONE,
	INT_IS_INT8,
	INT_IS_INT16,
	INT_IS_INT32,
	INT_IS_INT64,
	INT_IS_UINT8,
	INT_IS_UINT16,
	INT_IS_UINT32,
	INT_IS_UINT64,
	REAL_IS_FLOAT,
	REAL_IS_DOUBLE,
	INT_IS_CHAR16,
	INT_IS_CHAR32,
}

GDExtensionClassMethodCall :: proc(method_userdata: rawptr, p_instance: GDExtensionClassInstancePtr, p_args: GDExtensionConstVariantPtrargs, p_argument_count: GDExtensionInt, r_return: GDExtensionVariantPtr, r_error: ^GDExtensionCallError);
GDExtensionClassMethodValidatedCall :: proc(method_userdata: rawptr, p_instance: GDExtensionClassInstancePtr, p_args: GDExtensionConstVariantPtrargs, r_return: GDExtensionVariantPtr);
GDExtensionClassMethodPtrCall :: proc(method_userdata: rawptr, p_instance: GDExtensionClassInstancePtr, p_args: GDExtensionConstTypePtrargs, r_ret: GDExtensionTypePtr);


GDExtensionClassMethodInfo :: struct {
	name: GDExtensionStringNamePtr,
	method_userdata: rawptr,
	call_func: GDExtensionClassMethodCall,
	ptrcall_func: GDExtensionClassMethodPtrCall,
	method_flags: u32, // Bitfield of `GDExtensionClassMethodFlags`.

	/* If `has_return_value` is false, `return_value_info` and `return_value_metadata` are ignored.
	 *
	 * @todo Consider dropping `has_return_value` and making the other two properties match `GDExtensionMethodInfo` and `GDExtensionClassVirtualMethod` for consistency in future version of this struct.
	 */
	has_return_value: GDExtensionBool,
	return_value_info: ^GDExtensionPropertyInfo,
	return_value_metadata: GDExtensionClassMethodArgumentMetadata,

	/* Arguments: `arguments_info` and `arguments_metadata` are array of size `argument_count`.
	 * Name and hint information for the argument can be omitted in release builds. Class name should always be present if it applies.
	 *
	 * @todo Consider renaming `arguments_info` to `arguments` for consistency in future version of this struct.
	 */
	argument_count: u32,
	arguments_info: [^]GDExtensionPropertyInfo,
	arguments_metadata: ^GDExtensionClassMethodArgumentMetadata,

	/* Default arguments: `default_arguments` is an array of size `default_argument_count`. */
	default_argument_count: u32,
	default_arguments: ^GDExtensionVariantPtr,
}
/*
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

InterfaceGetProcAddress :: #type proc "c" (function_name: cstring) -> rawptr

/**
 * @name string_name_new_with_latin1_chars
 * @since 4.2
 *
 * Creates a StringName from a Latin-1 encoded C string.
 *
 * If `p_is_static` is true, then:
 * - The StringName will reuse the `p_contents` buffer instead of copying it.
 *   You must guarantee that the buffer remains valid for the duration of the application (e.g. string literal).
 * - You must not call a destructor for this StringName. Incrementing the initial reference once should achieve this.
 *
 * `p_is_static` is purely an optimization and can easily introduce undefined behavior if used wrong. In case of doubt, set it to false.
 *
 * @param r_dest A pointer to uninitialized storage, into which the newly created StringName is constructed.
 * @param p_contents A pointer to a C string (null terminated and Latin-1 or ASCII encoded).
 * @param p_is_static Whether the StringName reuses the buffer directly (see above).
 */
GDExtensionInterfaceStringNameNewWithLatin1Chars :: proc "c" (r_dest: GDExtensionUninitializedStringNamePtr, p_contents: cstring, p_is_static: GDExtensionBool)

/**
 * @name string_name_new_with_utf8_chars
 * @since 4.2
 *
 * Creates a StringName from a UTF-8 encoded C string.
 *
 * @param r_dest A pointer to uninitialized storage, into which the newly created StringName is constructed.
 * @param p_contents A pointer to a C string (null terminated and UTF-8 encoded).
 */
GDExtensionInterfaceStringNameNewWithUtf8Chars :: proc "c" (r_dest: GDExtensionUninitializedStringNamePtr, p_contents: cstring);

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


GDExtensionInterfaceClassdbRegisterExtensionClass2 :: proc "c" ( p_library: GDExtensionClassLibraryPtr,  p_class_name: GDExtensionConstStringNamePtr,  p_parent_class_name: GDExtensionConstStringNamePtr, p_extension_funcs: ^GDExtensionClassCreationInfo2)
GDExtensionInterfaceClassdbRegisterExtensionClass4 :: proc "c" ( p_library: GDExtensionClassLibraryPtr,  p_class_name: GDExtensionConstStringNamePtr,  p_parent_class_name: GDExtensionConstStringNamePtr, p_extension_funcs: ^GDExtensionClassCreationInfo4);


/**
 * @name classdb_register_extension_class_method
 * @since 4.1
 *
 * Registers a method on an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_method_info A pointer to a GDExtensionClassMethodInfo struct.
 */
GDExtensionInterfaceClassdbRegisterExtensionClassMethod :: proc(p_library: GDExtensionClassLibraryPtr, p_class_name: GDExtensionConstStringNamePtr, p_method_info: ^GDExtensionClassMethodInfo);


/**
 * @name classdb_register_extension_class_property
 * @since 4.1
 *
 * Registers a property on an extension class in the ClassDB.
 *
 * Provided struct can be safely freed once the function returns.
 *
 * @param p_library A pointer the library received by the GDExtension's entry point function.
 * @param p_class_name A pointer to a StringName with the class name.
 * @param p_info A pointer to a GDExtensionPropertyInfo struct.
 * @param p_setter A pointer to a StringName with the name of the setter method.
 * @param p_getter A pointer to a StringName with the name of the getter method.
 */
GDExtensionInterfaceClassdbRegisterExtensionClassProperty :: proc(p_library: GDExtensionClassLibraryPtr, p_class_name: GDExtensionConstStringNamePtr,
				p_info: ^GDExtensionPropertyInfo, p_setter: GDExtensionConstStringNamePtr, p_getter: GDExtensionConstStringNamePtr);

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

GDExtensionInterfaceGlobalGetSingleton :: proc "c" (p_name: GDExtensionConstStringNamePtr) -> GDExtensionObjectPtr


/**
 * @name variant_new_nil
 * @since 4.1
 *
 * Creates a new Variant containing nil.
 *
 * @param r_dest A pointer to the destination Variant.
 */
GDExtensionInterfaceVariantNewNil :: proc "c" (r_dest:GDExtensionUninitializedVariantPtr);

/* INTERFACE: String Utilities */

/**
 * @name string_new_with_latin1_chars
 * @since 4.1
 *
 * Creates a String from a Latin-1 encoded C string.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A cstring, a Latin-1 encoded C string (null terminated).
 * https://lemire.me/blog/2023/02/16/computing-the-utf-8-size-of-a-latin-1-string-quickly-avx-edition/
 * blog post discusses the latin1 encoding. Not certain why latin1 is preferred for a lot of Godot bindings.
 */
GDExtensionInterfaceStringNewWithLatin1Chars :: proc "c" (r_dest: GDExtensionUninitializedStringPtr, p_contents: cstring)



/**
 * @name string_new_with_utf8_chars
 * @since 4.1
 *
 * Creates a String from a UTF-8 encoded C string.
 *
 * @param r_dest A pointer to a Variant to hold the newly created String.
 * @param p_contents A pointer to a UTF-8 encoded C string (null terminated).
 */
GDExtensionInterfaceStringNewWithUtf8Chars :: proc(r_dest: GDExtensionUninitializedStringPtr, p_contents: cstring);


/**
 * @name get_variant_from_type_constructor
 * @since 4.1
 *
 * Gets a pointer to a function that can create a Variant of the given type from a raw value.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can create a Variant of the given type from a raw value.
 */
GDExtensionInterfaceGetVariantFromTypeConstructor :: proc(p_type: GDExtensionVariantType) -> GDExtensionVariantFromTypeConstructorFunc;




/**
 * @name print_warning_with_message
 * @since 4.1
 *
 * Logs a warning with a message to Godot's built-in debugger and to the OS terminal.
 *
 * @param p_description The code triggering the warning.
 * @param p_message The message to show along with the warning.
 * @param p_function The function name where the warning occurred.
 * @param p_file The file where the warning occurred.
 * @param p_line The line where the warning occurred.
 * @param p_editor_notify Whether or not to notify the editor.
 */
GDExtensionInterfacePrintWarningWithMessage :: proc "c" (p_description,p_message,p_function,p_file: cstring, p_line: i32, p_editor_notify: GDExtensionBool);



/**
 * @name get_variant_to_type_constructor
 * @since 4.1
 *
 * Gets a pointer to a function that can get the raw value from a Variant of the given type.
 *
 * @param p_type The Variant type.
 *
 * @return A pointer to a function that can get the raw value from a Variant of the given type.
 */
GDExtensionInterfaceGetVariantToTypeConstructor :: proc(p_type: GDExtensionVariantType) -> GDExtensionTypeFromVariantConstructorFunc;


/**
 * @name variant_get_type
 * @since 4.1
 *
 * Gets the type of a Variant.
 *
 * @param p_self A pointer to the Variant.
 *
 * @return The variant type.
 */
GDExtensionInterfaceVariantGetType :: proc(p_self: GDExtensionConstVariantPtr) -> GDExtensionVariantType;


/**
 * @name variant_get_ptr_operator_evaluator
 * @since 4.1
 *
 * Gets a pointer to a function that can evaluate the given Variant operator on the given Variant types.
 *
 * @param p_operator The variant operator.
 * @param p_type_a The type of the first Variant.
 * @param p_type_b The type of the second Variant.
 *
 * @return A pointer to a function that can evaluate the given Variant operator on the given Variant types.
 */
 GDExtensionInterfaceVariantGetPtrOperatorEvaluator :: proc(p_operator: GDExtensionVariantOperator, p_type_a: GDExtensionVariantType, p_type_b: GDExtensionVariantType) -> GDExtensionPtrOperatorEvaluator;


 
/**
 * @name classdb_get_method_bind
 * @since 4.1
 *
 * Gets a pointer to the MethodBind in ClassDB for the given class, method and hash.
 *
 * @param p_classname A pointer to a StringName with the class name.
 * @param p_methodname A pointer to a StringName with the method name.
 * @param p_hash A hash representing the function signature.
 *
 * @return A pointer to the MethodBind from ClassDB.
 */
 GDExtensionInterfaceClassdbGetMethodBind :: proc "c" (p_classname: GDExtensionConstStringNamePtr, p_methodname: GDExtensionConstStringNamePtr, p_hash: GDExtensionInt) -> GDExtensionMethodBindPtr

 
/**
 * @name object_method_bind_ptrcall
 * @since 4.1
 *
 * Calls a method on an Object (using a "ptrcall").
 *
 * @param p_method_bind A pointer to the MethodBind representing the method on the Object's class.
 * @param p_instance A pointer to the Object.
 * @param p_args A pointer to a C array representing the arguments.
 * @param r_ret A pointer to the Object that will receive the return value.
 */
GDExtensionInterfaceObjectMethodBindPtrcall :: proc "c" (p_method_bind: GDExtensionMethodBindPtr, p_instance: GDExtensionObjectPtr, p_args: GDExtensionConstTypePtrargs, r_ret: GDExtensionTypePtr);


/**
* @name variant_get_ptr_constructor
* @since 4.1
*
* Gets a pointer to a function that can call one of the constructors for a type of Variant.
*
* @param p_type The Variant type.
* @param p_constructor The index of the constructor.
*
* @return A pointer to a function that can call one of the constructors for a type of Variant.
*/
GDExtensionInterfaceVariantGetPtrConstructor :: proc "c" (p_type: GDExtensionVariantType, p_constructor: i32) -> GDExtensionPtrConstructor


/**
* @name classdb_register_extension_class_signal
* @since 4.1
*
* Registers a signal on an extension class in the ClassDB.
*
* Provided structs can be safely freed once the function returns.
*
* @param p_library A pointer the library received by the GDExtension's entry point function.
* @param p_class_name A pointer to a StringName with the class name.
* @param p_signal_name A pointer to a StringName with the signal name.
* @param p_argument_info A pointer to a GDExtensionPropertyInfo struct.
* @param p_argument_count The number of arguments the signal receives.
*/
GDExtensionInterfaceClassdbRegisterExtensionClassSignal :: proc "c" (p_library: GDExtensionClassLibraryPtr, p_class_name: GDExtensionConstStringNamePtr, p_signal_name: GDExtensionConstStringNamePtr, p_argument_info: ^GDExtensionPropertyInfo,  p_argument_count: GDExtensionInt);

/**
 * @name variant_destroy
 * @since 4.1
 *
 * Destroys a Variant.
 *
 * @param p_self A pointer to the Variant to destroy.
 */
GDExtensionInterfaceVariantDestroy :: proc "c" (p_self: GDExtensionVariantPtr);

/**
 * @name object_method_bind_call
 * @since 4.1
 *
 * Calls a method on an Object.
 *
 * @param p_method_bind A pointer to the MethodBind representing the method on the Object's class.
 * @param p_instance A pointer to the Object.
 * @param p_args A pointer to a C array of Variants representing the arguments.
 * @param p_arg_count The number of arguments.
 * @param r_ret A pointer to Variant which will receive the return value.
 * @param r_error A pointer to a GDExtensionCallError struct that will receive error information.
 */
GDExtensionInterfaceObjectMethodBindCall :: proc "c" (p_method_bind: GDExtensionMethodBindPtr, p_instance: GDExtensionObjectPtr, p_args: GDExtensionConstVariantPtrargs, p_arg_count: GDExtensionInt, r_ret: GDExtensionUninitializedVariantPtr, r_error: ^GDExtensionCallError);
