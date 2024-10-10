
#import "../../theme/asm.typ": *
#import "../../theme/theme.typ": *

#set page(width: 297mm, height: 210mm)
#set page(margin: 10mm)

#place(bottom + center, dy: 0.45cm)[
  Архитектура компьютеров и операционные системы, МФТИ, 10 октября 2024.
]

#grid(columns: (50%, 50%),
[
  = Семинар 5 - Ассемблер AArch64.

  == Задача

  Реализуйте функцию #raw("_print_list") на ассемблере AArch64. Функция принимает указатель на первый элемент связного списка и должна вывести в консоль содержимое полей #raw("element") всех элементов используя функцию #raw("puts")

  == Заголовочный файл:

  #code(numbers: true, ```c
  typedef struct list_entry {
    struct list_entry* next;
    const char* element;
  } list_entry;

  void print_list(list_entry* first);
  ```)  

  == Заготовка:

  #lightasmtable(numbers: true, inset: 0.2em, ```asm
  _print_list:
    sub sp, sp, 32
    stp x29, x30, [sp, +16]
    mov x29, sp
    # <ваш код>



    # Заготовка: печать первого элемента
    ldr x0, [x0, 8] # x0 = first->element
    bl _puts        # puts(first->element)




    # </ваш код>
    ldp x29, x30, [sp, +16]
    add sp, sp, 32
    ret
  ```)


], [
    #show heading: (content) => {
      set block(below: 0.6em, above: 0.8em)
      content
    }
    #set table(stroke: none, inset: (x: 5pt, y: 2pt))
    == Инструкции обработки данных
    #table(columns: 2, 
      [#lightasm("ADD <Rd>, <Rn>, <Rm>"):], [#raw(lang: "c", "Rd = Rn + Rm;")],
      [#lightasm("SUB <Rd>, <Rn>, <Rm>"):], [#raw(lang: "c", "Rd = Rn - Rm;")],
      [#lightasm("MUL <Rd>, <Rn>, <Rm>"):], [#raw(lang: "c", "Rd = Rn * Rm;")]
    )

    == Инструкции load / store
    #table(columns: 2, 
      [#lightasm("LDR <Rt>, [<Rn>]"):], [#raw(lang: "c", "Rt = *Rn;")],
      [#lightasm("LDR <Rt>, [<Rn>, <imm>]"):], [#raw(lang: "c", "Rt = *(Rn + imm);")],
      [#lightasm("LDR <Rt>, [<Rn>, <imm>]!"):], [#raw(lang: "c", "Rt = *(Rn += imm);")],
      [#lightasm("LDR <Rt>, [<Rn>], <imm>"):], [#raw(lang: "c", "Rt = *(Rn); Rn += imm;")],
      [#lightasm("STR <Rt>, [<Rn>]"):], [#raw(lang: "c", "*Rn = Rt;")],
      [#lightasm("STR <Rt>, [<Rn>, <imm>]"):], [#raw(lang: "c", "*(Rn + imm) = Rt;")],
      [#lightasm("STR <Rt>, [<Rn>, <imm>]!"):], [#raw(lang: "c", "*(Rn += imm) = Rt;")],
      [#lightasm("STR <Rt>, [<Rn>], <imm>"):], [#raw(lang: "c", "*(Rn) = Rt; Rn += imm;")],
      [], [],
      [#lightasm("STP <Ra>, <Rb> -||-"):], [Аналогично, но сохраняет два регистра],
      [#lightasm("LDP <Ra>, <Rb> -||-"):], [Аналогично, но загружает два регистра],
    )

    == Инструкции перехода
    #table(columns: 2, 
      [#lightasm("B <label>"):], [#raw(lang: "c", "goto label")],
      [#lightasm("BL <label>"):], [#lightasm("call"), или #raw(lang: "c", "goto label") + #raw("r30 = <return address>")],
      [#lightasm("RET"):], [#mnemonic("return"), или #raw(lang: "c", "goto r30")]
    )

    == Логические инструкции
    #table(columns: 2, 
      [#lightasm("AND <Rd>, <Rn>, <Rm>"):], [#raw(lang: "c", "Rd = Rn & Rm;")],
      [#lightasm("ORR <Rd>, <Rn>, <Rm>"):], [#raw(lang: "c", "Rd = Rn | Rm;")],
      [#lightasm("EOR <Rd>, <Rn>, <Rm>"):], [#raw(lang: "c", "Rd = Rn ^ Rm;")]
    )

    == Условные суффиксы
    Чтобы изменить флаги, *добавь суффикс #mnemonic("s")*
    #table(columns: 4, 
      [#lightasm(".EQ"):], [Если равно],
      [#lightasm(".NE"):], [Если не равно],
      [#lightasm(".HS"):], [Если беззнаково $>=$],
      [#lightasm(".LO"):], [Если беззнаково $<$],
      [#lightasm(".MI"):], [Если отрицательно],
      [#lightasm(".PL"):], [Если положительно или ноль],
      [#lightasm(".VS"):], [Если переполнение],
      [#lightasm(".VC"):], [Если нет переполнения],
      [#lightasm(".HI"):], [Если беззнаково $>$],
      [#lightasm(".LS"):], [Если беззнаково $<=$],
      [#lightasm(".GE"):], [Если знаково $>=$],
      [#lightasm(".LT"):], [Если знаково $<$],
      [#lightasm(".GT"):], [Если знаково $>$],
      [#lightasm(".LE"):], [Если знаково $<=$]
    )    
])