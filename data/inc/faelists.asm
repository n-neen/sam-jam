faelist: {
    macro fae_list_entry(type, x, y, var1, var2, var3)
        dw <type>
        dw <x>
        dw <y>
        dw <var1>
        dw <var2>
        dw <var3>
    endmacro
    
    .definitionstart:
        ;this is used in defines.asm to determine the length of each entry
                        ;type    x      y      var1   var2   var3
        %fae_list_entry ($0123, $4567, $89ab, $cdef, $0123, $4567)
    .definitionend:
    
;========================================== fae lists ======================================
    
    
    .room1: {
                        ;type       x      y     var1            var2   var3
        ;%fae_list_entry (fae_door, $00f8, $00f8, scenedef_room2, $0000, $0000)   
        
        
        %fae_list_entry (fae_test, $0080, $0080, $0001, $0000, $0000)
        %fae_list_entry (fae_test, $0090, $0090, $0002, $0000, $0000)
        %fae_list_entry (fae_test, $00b0, $00b0, $0003, $0000, $0000)
        %fae_list_entry (fae_test, $00c0, $00c0, $0003, $0000, $0000)
        %fae_list_entry (fae_test, $00d0, $00c0, $0003, $0000, $0000)
        %fae_list_entry (fae_test, $00e0, $00c0, $0003, $0000, $0000)
        %fae_list_entry (fae_test, $0120, $00c0, $0003, $0000, $0000)
        %fae_list_entry (fae_test, $0130, $0100, $0003, $0000, $0000)
        %fae_list_entry (fae_test, $0150, $0120, $0003, $0000, $0000)
        %fae_list_entry (fae_test, $0170, $0130, $0003, $0000, $0000)
        dw $ffff
    }
    
    
    .overworld: {
        ;
        dw $ffff
    }
}