bits 32

global fadecircle

SECTION .text
align 4

%define ibuffer   ebp+8
%define iwidth    ebp+12
%define iheight   ebp+16
%define center_x  ebp+20
%define center_y  ebp+24
%define radius    ebp+28
%define color     ebp+32

fadecircle:
    ;function prologue

    push    ebp                     
    mov     ebp, esp                

    sub     esp, 12

    push    ebx
    push    esi
    push    edi

    
    mov     DWORD [ebp-8], 0        ;pos_y

loop_y:

    mov     DWORD [ebp-4], 0        ;pos_x
    
loop_main:

    mov     edi, [ebp-4]            ;store pos_x in edi
    mov     eax, [ebp-8]            ;store pos_y in eax

    mov     ecx, [iwidth]           
    lea     edx, [ecx+ecx*2]        ;store width*3 in edx
    and     ecx, 0x3
    add     ecx, edx
    
    imul    ecx, eax
    add     ecx, [ibuffer]

    mov     ebx, edi
    lea     ebx, [ebx+ebx*2]        ;store pos_x*3 in ebx
    add     ebx, ecx

    sub     eax, [center_y]         ;y - center_y
    imul    eax, eax            

    sub     edi, [center_x]         ;x - center_x
    imul    edi, edi

    add     eax, edi                ;y^2 + x^2

    mov     edx, [radius]
    mov     ecx, edx
    imul    edx, edx
    cmp     eax, edx                ;distance between inner circle and radius

    jb      ignore_pixel            ;if < radius       

    shl     ecx, 1                  ;redius*2
    imul    ecx, ecx                ;(radius*2)^2

    cmp     eax, ecx                ;distance between outter circle and radius
    ja      simple_pixel            ;if > radius

lerping_pixel:
    ;fading the color

    ;calculate klerp
    sub     eax, edx                ;distance^2 - radius^2
    shl     eax, 8                  ;*256
    sub     ecx, edx                ;outter^2 - inner^2
    cdq
    idiv    ecx
    mov     esi, eax

    mov     edi, ebx

    movzx   edx, WORD [edi+2]       ;load the blue component to edx
    mov     ecx, edx
    mov     eax, [color]
    mov     dl, al

    ;calculate interpolated_color(blue component)
    mov     eax, 256
    sub     eax, esi                ;256 - klerp
    imul    eax, ecx                ;(256 - klerp) * color
    mov     ecx, esi            
    imul    ecx, edx                ;color*klerp
    add     eax, ecx                ;(256 - klerp) * color + color * klerp
    shr     eax, 8                  ;div 256

    mov     [edi + 2], al

    movzx   edx, WORD [edi+1]       ;load the green component to edx
    mov     ecx, edx
    mov     eax, [color]
    shr     eax, 8
    mov     dl, al

    ;calculate interpolated_color(green component)
    mov     eax, 256
    sub     eax, esi
    imul    eax, ecx
    mov     ecx, esi
    imul    ecx, edx
    add     eax, ecx
    shr     eax, 8

    mov     [edi + 1], al

    movzx   edx, WORD [edi]         ;load the red component
    mov     ecx, edx
    mov     eax, [color]
    shr     eax, 16
    mov     dl, al

    ;calculate interpolated_color(red component)
    mov     eax, 256
    sub     eax, esi
    imul    eax, ecx
    mov     ecx, esi
    imul    ecx, edx
    add     eax, ecx
    shr     eax, 8

    mov     [edi], al

    jmp     ignore_pixel

simple_pixel:
    ;color without fade

    mov     eax, [color]
    mov     dl, al
    mov     [ebx+2], dl
    shr     eax, 8
    mov     dl, al
    mov     [ebx+1], dl
    shr     eax, 8
    mov     dl, al
    mov     [ebx], dl

ignore_pixel:

    inc     dword [ebp-4]           ;increment ebp-4
    mov     eax, [ebp-4]
    cmp     eax, [iwidth]
    jb      loop_main               ;jump if pos_x < iwidth

done_x:

    inc     dword [ebp-8]           ;increment ebp-8
    mov     eax, [ebp-8]
    cmp     eax, [iheight]          
    jb      loop_y                  ;jump if pos_y < iheight

done:
    ;function epilogue

    pop     edi
    pop     esi
    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret