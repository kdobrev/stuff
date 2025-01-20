DATA: lt_table   TYPE REF TO data,
      lo_struct  TYPE REF TO cl_abap_structdescr,
      lt_fields  TYPE abap_compdescr_tab,
      lv_sum     TYPE i.

FIELD-SYMBOLS: <fs_table>    TYPE STANDARD TABLE,
               <fs_line>     TYPE ANY,
               <fs_field>    TYPE ANY.

" Create a dynamic internal table
DATA(lo_table_type) = cl_abap_tabledescr=>create( 
                      p_line_type = cl_abap_structdescr=>create(
                        VALUE #( ( name = 'COL1' type = cl_abap_elemdescr=>get_integer( ) )
                                 ( name = 'COL2' type = cl_abap_elemdescr=>get_integer( ) )
                                 ( name = 'COL3' type = cl_abap_elemdescr=>get_integer( ) ) ) ) ).

CREATE DATA lt_table TYPE HANDLE lo_table_type.
ASSIGN lt_table->* TO <fs_table>.

" Populate the dynamic internal table
APPEND VALUE #( COL1 = 10 COL2 = 20 COL3 = 30 ) TO <fs_table>.
APPEND VALUE #( COL1 = 5  COL2 = 15 COL3 = 25 ) TO <fs_table>.
APPEND VALUE #( COL1 = 7  COL2 = 14 COL3 = 21 ) TO <fs_table>.

" Get the structure description of the dynamic table's line type
lo_struct ?= cl_abap_typedescr=>describe_by_data( <fs_table> ).
lt_fields = lo_struct->components.

" Use REDUCE to sum all columns in all rows dynamically
lv_sum = REDUCE i( 
  INIT total = 0 
  FOR <fs_line> IN <fs_table> 
  NEXT total = total + REDUCE i(
    INIT row_sum = 0
    FOR <fs_component> IN lt_fields
    NEXT row_sum = row_sum + VALUE #( 
      LET field_val = VALUE #( 
        ASSIGN COMPONENT <fs_component>-name 
        OF STRUCTURE <fs_line> TO <fs_field>. 
        IF sy-subrc = 0. 
          <fs_field>. 
        ELSE. 
          0. 
        ENDIF. ) 
      IN field_val ) ) ).

" Output the result
WRITE: / 'Total Sum of All Columns:', lv_sum.