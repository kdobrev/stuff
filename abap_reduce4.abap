DATA: lt_table   TYPE REF TO data,
      lt_totals  TYPE REF TO data,
      lo_struct  TYPE REF TO cl_abap_structdescr,
      lt_fields  TYPE abap_compdescr_tab.

FIELD-SYMBOLS: <fs_table>    TYPE STANDARD TABLE,
               <fs_line>     TYPE any,
               <fs_totals>   TYPE any,
               <fs_value>    TYPE any,
               <fs_total>    TYPE any.

" Create a dynamic internal table
DATA(lo_table_type) = cl_abap_tabledescr=>create( 
                      p_line_type = cl_abap_structdescr=>create(
                        VALUE #( ( name = 'COL1' type = cl_abap_elemdescr=>get_integer( ) )
                                 ( name = 'COL2' type = cl_abap_elemdescr=>get_integer( ) )
                                 ( name = 'COL3' type = cl_abap_elemdescr=>get_integer( ) ) ) ) ).

CREATE DATA lt_table TYPE HANDLE lo_table_type.
ASSIGN lt_table->* TO <fs_table>.

" Populate the dynamic internal table
APPEND INITIAL LINE TO <fs_table> ASSIGNING FIELD-SYMBOL(<fs_populate>).
<fs_populate>-COL1 = 10. <fs_populate>-COL2 = 20. <fs_populate>-COL3 = 30.

APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_populate>.
<fs_populate>-COL1 = 5.  <fs_populate>-COL2 = 15. <fs_populate>-COL3 = 25.

APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_populate>.
<fs_populate>-COL1 = 7.  <fs_populate>-COL2 = 14. <fs_populate>-COL3 = 21.

" Get the structure description of the dynamic table's line type
lo_struct ?= cl_abap_typedescr=>describe_by_data( <fs_table> ).
lt_fields = lo_struct->components.

" Create a structure for totals and initialize
CREATE DATA lt_totals TYPE HANDLE lo_struct.
ASSIGN lt_totals->* TO <fs_totals>.

" Use REDUCE to calculate column totals
LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<fs_field>).
  ASSIGN COMPONENT <fs_field>-name OF STRUCTURE <fs_totals> TO <fs_total>.
  IF sy-subrc = 0.
    <fs_total> = REDUCE i(
      INIT total = 0
      FOR <fs_line> IN <fs_table>
      NEXT total = total + CONV i(
        IF ASSIGN COMPONENT <fs_field>-name OF STRUCTURE <fs_line> TO <fs_value>
        THEN <fs_value>
        ELSE 0
        ENDIF
      )
    ).
  ENDIF.
ENDLOOP.

" Append totals as the last row
APPEND <fs_totals> TO <fs_table>.

" Output the table using modern syntax
LOOP AT <fs_table> ASSIGNING <fs_line>.
  DATA(output) = REDUCE string(
    INIT text = ``
    FOR <fs_field> IN lt_fields
    NEXT text = text && | { <fs_field>-name } = { CONV string( ASSIGN COMPONENT <fs_field>-name OF STRUCTURE <fs_line> TO <fs_value> ? <fs_value> ELSE '0' ) } |
  ).
  WRITE: / output.
ENDLOOP.