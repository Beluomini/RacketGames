;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Frogger) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp") (lib "batch-io.rkt" "teachpack" "2htdp")) #f)))

(require 2htdp/image)
(require 2htdp/universe)



;;;; ---------------------------------------------------------------------------
;;;; DATA DEFINITIONS:

;;; Definições das constantes
; Tela
(define LARGURA-TELA 10)
(define MAX-X 74)   ; max x cordenada do fundo
(define MAX-Y 70)   ; max y cordenada do fundo
(define HEIGHT (* LARGURA-TELA MAX-Y))  ; altura da tela
(define WIDTH (* LARGURA-TELA MAX-X))   ; largura da tela
(define MIN-RIO 5)  ; min y cordenada da area do rio
(define MAX-RIO 31) ; max y cordenada da area do rio
(define AREA-RIO
  (rectangle (* LARGURA-TELA MAX-X)
             (* LARGURA-TELA (- MAX-RIO MIN-RIO))
             'solid 'LightCyan))   ; river area
(define BG (place-image AREA-RIO
                        (/ (* LARGURA-TELA MAX-X) 2)
                        (* (/ (+ MAX-RIO MIN-RIO) 2) LARGURA-TELA)
                        (empty-scene WIDTH HEIGHT)))  ; background

; Frog
(define F-IMG-U  ; Imagem do sapo quando direcionado para cima "up"
  (bitmap "img/frog_up.png")) 
(define F-IMG-D  ; Imagem do sapo quando direcionado para baixo "down"
  (bitmap "img/frog_down.png")) 
(define F-IMG-R  ; Imagem do sapo quando direcionado para direita "right"
  (bitmap "img/frog_right.png")) 
(define F-IMG-L  ; Imagem do sapo quando direcionado para esquerda "left"
  (bitmap "img/frog_left.png")) 
(define FROG-PASSO 5)  ; Tamanho do passo do sapo
(define F-TAMANHO
  (/ (image-height F-IMG-U) LARGURA-TELA))  ; tamanho do sapo

; Carro
(define C-IMG-R ; carro quando sua direção é direita "right"
  (bitmap "img/vehicle_right.png")) 
(define C-IMG-L ; carro quando sua direção é esquerda "left"
  (bitmap "img/vehicle_left.png")) 
(define C-LARGURA (/ (image-width C-IMG-R) LARGURA-TELA)) ; largura do carro
(define C-ALTURA (/ (image-height C-IMG-R) LARGURA-TELA))  ; altura do carro
(define DISTANCIA-ENTRE-CARROS 14)  ; distancia entre os carros
(define C-NUM 4)  ; numero de carros por linha
(define V-TOTAL-L ; tamanho total de todos os carros e espaços em cada linha
  (* C-NUM (+ C-LARGURA DISTANCIA-ENTRE-CARROS)))

; Tronco
(define TR-IMG (bitmap "img/plank.png"))   ; imagem do tronco
(define TR-LARGURA (/ (image-width TR-IMG) LARGURA-TELA))   ; largura do tronco
(define TR-ALTURA (/ (image-height TR-IMG) LARGURA-TELA))   ; altura do tronco
(define DISTANCIA-ENTRE-TRONCOS 10)  ; distancia entre os troncos
(define TR-NUM 4)   ; numero de troncos por linha
(define TR-TOTAL-L  ; tamanho total de todos os troncos e espaços em cada linha
  (* TR-NUM (+ TR-LARGURA DISTANCIA-ENTRE-TRONCOS)))

; tartaruga
(define T-IMG (bitmap "img/turtle.png"))   ; image that represents a tartaruga
(define T-L    ; tartaruga image size
  (/ (image-height T-IMG) LARGURA-TELA))   
(define DISTANCE-BETWEEN-TS 16)  ; distance bewteen two separated tartarugas
(define T-NUM 3)     ; number of tartarugas for group
(define T-GROUPS 3)  ; number of tartaruga groups per row
(define T-TOTAL-L    ; total length of all tartarugas and gaps in each row
  (* T-GROUPS (+ (* T-L T-NUM) DISTANCE-BETWEEN-TS)))

; Information  ; 
(define VIDAS-INICIAIS 3)   ; numero de vidas iniciais
(define PONTUACAO-INICIAL 500) ; pontuação inicial
(define TAMANHO-FONTE-INFO 20)  ; tamanho da fonte das informaçoes (score and lives)
(define PONTUACAO-INICIAL-X 8)     ; coordenada x da pontuação inicial
(define VIDAS-INICIAIS-X 20)    ; coordenada x das vidas iniciais
(define INFO-Y 68)          ; coordenada y das informaçoes
(define VITORIA-FROG (bitmap "img/win_frog.png"))   ; tela de vitoria
(define GAME-OVER  ; tela de derrota     
  (place-image (text "Game Over :(" 40 'red)
               (/ WIDTH 2) (/ HEIGHT 2)
               (empty-scene WIDTH HEIGHT)))

(define WIN        ; tela aparece quando o jogador ganha
  (place-image (text "Win! :)" 40 'green) (/ WIDTH 2) (/ HEIGHT 2)
               (place-image VITORIA-FROG 200 200
                            (empty-scene WIDTH HEIGHT))))

(define DIFICULDADE 5)  ; objetos se movem mais rápido quanto maior o valor


;;; Direções
;; - Esquerda "left"
;; - Direita "right"
;; - Cima "up"
;; - Baixo "down"


;;;; Definição de jogador
;;; o jogador é um (make-jogador Number Number Direction)
;; INTERP: representa as coordenadas x e y do jogador e a direção que ele está
(define-struct jogador (x y dir))

;; Exemplos:
(define jogador0 (make-jogador 37 63 "up"))
(define jogador1 (make-jogador 37 63 "down"))
(define jogador2 (make-jogador 37 63 "left"))
(define jogador3 (make-jogador 37 63 "right"))


;;; definição de carro
;;; O carro é um (make-carro Number Number Direction)
(define-struct carro (x y dir))

;; Exemplos:
(define c1 (make-carro 8 58 "right"))
(define c2 (make-carro 28 58 "right"))
(define c3 (make-carro 48 58 "right"))
(define c4 (make-carro 68 58 "right"))
(define c5 (make-carro 6 53 "left"))
(define c6 (make-carro 26 53 "left"))
(define c7 (make-carro 46 53 "left"))
(define c8 (make-carro 66 53 "left"))
(define c9 (make-carro 2 48 "right"))
(define c10 (make-carro 22 48 "right"))
(define c11 (make-carro 42 48 "right"))
(define c12 (make-carro 62 48 "right"))
(define c13 (make-carro 8 43 "left"))
(define c14 (make-carro 28 43 "left"))
(define c15 (make-carro 48 43 "left"))
(define c16 (make-carro 68 43 "left"))
(define c17 (make-carro 4 38 "right"))
(define c18 (make-carro 24 38 "right"))
(define c19 (make-carro 44 38 "right"))
(define c20 (make-carro 64 38 "right"))


;;; definição de lista de carros
;;; [Lista-de-carros]

;; Exemplos:
(define ldc0 '())
(define ldc1 (list c1 c2 c3 c4 c5 c6 c7 c8 c9 c10
                   c11 c12 c13 c14 c15 c16 c17 c18 c19 c20))
(define ldc2 (list c1))


;;; definicao de tronco
;;; O tronco é um (make-tronco Number Number Direction)
(define-struct tronco (x y dir))

;; Exemplos:
(define tr1 (make-tronco -2 28 "right"))
(define tr2 (make-tronco 20 28 "right"))
(define tr3 (make-tronco 42 28 "right"))
(define tr4 (make-tronco 64 28 "right"))
(define tr5 (make-tronco 5 18 "right"))
(define tr6 (make-tronco 27 18 "right"))
(define tr7 (make-tronco 49 18 "right"))
(define tr8 (make-tronco 71 18 "right"))
(define tr9 (make-tronco 0 8 "right"))
(define tr10 (make-tronco 22 8 "right"))
(define tr11 (make-tronco 44 8 "right"))
(define tr12 (make-tronco 66 8 "right"))


;;; definicao de lista de troncos
;;; [Lista-de-troncos]

;; Exemplos
(define lotr0 '())
(define lotr1 (list tr1 tr2 tr3 tr4 tr5 tr6 tr7 tr8 tr9 tr10 tr11 tr12))
(define lotr2 (list tr1))


;;; definicao de tartaruga
;;; A Tartaruga é uma (make-tartaruga Number Number Direction)
(define-struct tartaruga (x y dir))

;; Exemplos:
(define t1 (make-tartaruga 2 23 "left"))
(define t2 (make-tartaruga 6 23 "left"))
(define t3 (make-tartaruga 10 23 "left"))
(define t4 (make-tartaruga 30 23 "left"))
(define t5 (make-tartaruga 34 23 "left"))
(define t6 (make-tartaruga 38 23 "left"))
(define t7 (make-tartaruga 58 23 "left"))
(define t8 (make-tartaruga 62 23 "left"))
(define t9 (make-tartaruga 66 23 "left"))
(define t10 (make-tartaruga 11 13 "left"))
(define t11 (make-tartaruga 15 13 "left"))
(define t12 (make-tartaruga 19 13 "left"))
(define t13 (make-tartaruga 39 13 "left"))
(define t14 (make-tartaruga 43 13 "left"))
(define t15 (make-tartaruga 47 13 "left"))
(define t16 (make-tartaruga 67 13 "left"))
(define t17 (make-tartaruga 71 13 "left"))
(define t18 (make-tartaruga 75 13 "left"))


;;; Definição de Lista de Tartarugas
;;; [Lista-de-tartaruga]

;; Exemplo:
(define ldt0 '())
(define ldt1 (list t1 t2 t3 t4 t5 t6 t7 t8 t9 t10
                   t11 t12 t13 t14 t15 t16 t17 t18))
(define lot2 (list t1))


;;; Definicao de informações
;;; A informação é uma (make-info number number)
(define-struct info (score lives))

;; Exemplo:
(define info0 (make-info PONTUACAO-INICIAL VIDAS-INICIAIS))


;;; Definition of World
;;; A World is a
;; (make-world jogador [List-of carro] [List-of tronco] [List-of tartarugas])
(define-struct world (jogador carros troncos tartarugas info))

;; Exemplos:
(define MUNDO-VAZIO (make-world jogador0 ldc0 lotr0 ldt0 info0))
(define MUNDO0 (make-world jogador0 ldc1 lotr1 ldt1 info0))
(define MUNDO-S (make-world jogador0 ldc2 lotr2 lot2 info0))



;;;; ---------------------------------------------------------------------------
;;;; FUNCTIONS:

;;; Drawing the world

;; draw-all: World -> Image
;; draw the world base on condition
(define (draw-all aw)
  (if (dead? aw) (draw-world (reset-world aw)) (draw-world aw)))

;; draw-world: World -> Image
;; draw the current world
(check-expect (draw-world MUNDO-VAZIO)
              (place-image F-IMG-U 370 630
                           (place-image (text "Score: 500" 20 'green) 80 680
                                        (place-image (text "Lives: 3" 20 'green) 200 680 BG))))
(check-expect (draw-world MUNDO-S)
              (place-image F-IMG-U 370 630
                           (place-image C-IMG-R 80 580
                                        (place-image TR-IMG -20 280
                                                     (place-image T-IMG 20 230
                                                                  (place-image (text "Score: 500" 20 'green) 80 680
                                                                               (place-image (text "Lives: 3" 20 'green) 200 680    
                                                                                            BG)))))))
(define (draw-world aw)
  (draw-jogador (world-jogador aw)
               (draw-carros (world-carros aw)
                              (draw-troncos (world-troncos aw)
                                           (draw-tartarugas (world-tartarugas aw)
                                                         (draw-score (info-score (world-info aw))
                                                                     (draw-lives (info-lives (world-info aw))
                                                                                 BG)))))))

;; draw-jogador: jogador Image -> Image
;; draw the image of a frog on another image based on the frog's direction
(check-expect (draw-jogador jogador0 BG) (place-image F-IMG-U 370 630 BG))
(check-expect (draw-jogador jogador1 BG) (place-image F-IMG-D 370 630 BG))
(check-expect (draw-jogador jogador2 BG) (place-image F-IMG-L 370 630 BG))
(check-expect (draw-jogador jogador3 BG) (place-image F-IMG-R 370 630 BG))
(define (draw-jogador ap img)
  (cond [(string=? (jogador-dir ap) "up")
         (draw (jogador-x ap) (jogador-y ap) F-IMG-U img)]
        [(string=? (jogador-dir ap) "down")
         (draw (jogador-x ap) (jogador-y ap) F-IMG-D img)]
        [(string=? (jogador-dir ap) "left")
         (draw (jogador-x ap) (jogador-y ap) F-IMG-L img)]
        [(string=? (jogador-dir ap) "right")
         (draw (jogador-x ap) (jogador-y ap) F-IMG-R img)]))

;; draw: Number Number Image Image -> Image
;; draw image1 on image2
(check-expect (draw 1 1 F-IMG-U BG) (place-image F-IMG-U 10 10 BG))
(define (draw x y img1 img2)
  (place-image img1 (* LARGURA-TELA x) (* LARGURA-TELA y) img2))

;; draw-carros: [List-of carro] Image -> Image
;; draw the given set of carros on an image
(check-expect (draw-carros ldc0 BG) BG)
(check-expect (draw-carros ldc2 BG) (place-image C-IMG-R 80 580 BG))
(define (draw-carros alov img)
  ;; [carro Image -> Image] Image [List-of carro] -> Image
  (foldr draw-one-v img alov))

;; draw-one-v: carro Image -> Image
;; draw the image of the given carro on another image
(check-expect (draw-one-v c1 BG) (place-image C-IMG-R 80 580 BG))
(check-expect (draw-one-v c5 BG) (place-image C-IMG-L 60 530 BG))
(define (draw-one-v av img)
  (cond [(string=? (carro-dir av) "left")
         (draw (carro-x av) (carro-y av) C-IMG-L img)]
        [(string=? (carro-dir av) "right")
         (draw (carro-x av) (carro-y av) C-IMG-R img)]))

;; draw-troncos: [List-of tronco] Image -> Image
;; draw the given set of troncos on an image
(check-expect (draw-troncos lotr0 BG) BG)
(check-expect (draw-troncos lotr2 BG) (place-image TR-IMG -20 280 BG))
(define (draw-troncos alop img)
  ;; [tronco Image -> Image] Image [List-of tronco] -> Image
  (foldr (λ (p i) (draw (tronco-x p) (tronco-y p) TR-IMG i)) img alop))

;; draw-tartarugas: [List-of tartaruga] Image -> Image
;; draw the given set of tartarugas on an image
(check-expect (draw-tartarugas ldt0 BG) BG)
(check-expect (draw-tartarugas lot2 BG) (place-image T-IMG 20 230 BG))
(define (draw-tartarugas alot img)
  ;; [tartaruga Image -> Image] Image [List-of tartaruga] -> Image
  (foldr (λ (t i) (draw (tartaruga-x t) (tartaruga-y t) T-IMG i)) img alot))

;; draw-info: Info Image -> Image
;; draw the game information on an image
(check-expect (draw-info info0 BG)
              (place-image (text "Score: 500" 20 'green) 80 680
                           (place-image (text "Lives: 3" 20 'green) 200 680
                                        BG)))
(define (draw-info i img)
  (draw-score (info-score i)
              (draw-lives (info-lives i) img)))                   

;; draw-score: Number Image -> Image
;; produce the game score as an image
(check-expect (draw-score 1000 BG)
              (place-image (text "Score: 1000" 20 'green) 80 680 BG))
(define (draw-score score img)
  (draw PONTUACAO-INICIAL-X INFO-Y
        (text (string-append "Score: " (number->string score))
              TAMANHO-FONTE-INFO 'green)
        img))

;; draw-lives: Number Image -> Image
;; produce the currentn number of lives as an image
(check-expect (draw-lives 3 BG)
              (place-image (text "Lives: 3" 20 'green) 200 680 BG))
(define (draw-lives lives img)
  (draw VIDAS-INICIAIS-X INFO-Y
        (text (string-append "Lives: " (number->string lives))
              TAMANHO-FONTE-INFO 'green)
        img))



;;; Moving

;; move-all: World -> World
;; move the world base on condition
(define (move-all aw)
  (if (dead? aw) (move-world (reset-world aw)) (move-world aw)))

;; move-world: World -> World
;; move the given world at each tick
(check-expect (move-world MUNDO-VAZIO)
              (make-world jogador0 ldc0 lotr0 ldt0 (make-info 499 3)))
(check-expect (move-world MUNDO-S)
              (make-world jogador0
                          (list (make-carro 9 58 "right"))
                          (list (make-tronco -1 28 "right"))
                          (list (make-tartaruga 1 23 "left"))
                          (make-info 499 3)))
(define (move-world aw)
  (make-world (ride-move (world-jogador aw)
                         (world-troncos aw)
                         (world-tartarugas aw))
              (move-carros (world-carros aw))
              (move-troncos (world-troncos aw))
              (move-tartarugas (world-tartarugas aw))
              (make-info (change-score (info-score (world-info aw)))
                         (info-lives (world-info aw)))))

;; move-carros: [List-of carro] -> [List-of carro]
;; move the given list of carros at each tick
(check-expect (move-carros ldc0) ldc0)
(check-expect (move-carros ldc2) (list (make-carro 9 58 "right")))
(check-expect (move-carros (list c5)) (list (make-carro 5 53 "left")))
(define (move-carros alov)
  ;; [carro -> carro] [List-of carro] -> [List-of carro]
  (map move-a-carro alov))

;; move-a-carro: carro -> carro
;; move a given carro at each tick
(check-expect (move-a-carro c1) (make-carro 9 58 "right"))
(check-expect (move-a-carro (make-carro 77 27 "right"))
              (make-carro -2 27 "right"))
(check-expect (move-a-carro c5) (make-carro 5 53 "left"))
(check-expect (move-a-carro (make-carro -3 22 "left"))
              (make-carro 76 22 "left"))
(check-expect (move-a-carro (make-carro 10 10 "up"))
              (make-carro 10 10 "up"))
(check-expect (move-a-carro (make-carro 20 20 "down"))
              (make-carro 20 20 "down"))
(define (move-a-carro av)
  (cond [(string=? (carro-dir av) "right")
         (make-carro (move-right (carro-x av) C-LARGURA V-TOTAL-L)
                       (carro-y av) (carro-dir av))]
        [(string=? (carro-dir av) "left")
         (make-carro (move-left (carro-x av) C-LARGURA V-TOTAL-L)
                       (carro-y av) (carro-dir av))]
        [else av]))

;; move-right: Number PosReal PosReal-> Number
;; change the x coordinate for an entity that goes right
(check-expect (move-right 8 6 80) 9)
(check-expect (move-right 77 6 80) -2)
(define (move-right x l total-l)
  (if (<= (add1 x) (+ MAX-X (/ l 2)))
      (add1 x)
      (- (add1 x) total-l)))

;; move-left: Number PosReal PosReal -> Number
;; change the x coordinate for an entity that goes left
(check-expect (move-left 8 6 80) 7)
(check-expect (move-left -3 6 80) 76)
(define (move-left x l total-l)
  (if (>= (sub1 x) (- (/ l 2)))
      (sub1 x)
      (+ (sub1 x) total-l)))

;;> decided not to use abstract function for move-right and move-left,
;;> because the abstract function would take 6 parameters: x, l, total-l,
;;> otr1 (<= or >=), otr2 (add1 or sub1) and otr3 (- or +), whick is cumbersome
;;> and not very helpful.

;; move-troncos: [List-of tronco] -> [List-of tronco]
(check-expect (move-troncos lotr2) (list (make-tronco -1 28 "right")))
(check-expect (move-troncos (list (make-tronco 80 28 "right")))
              (list (make-tronco -7 28 "right")))
(define (move-troncos alop)
  ;; [tronco -> tronco] [List-of tronco] -> [List-of tronco]
  (map (λ (p) (make-tronco (move-right (tronco-x p) TR-LARGURA TR-TOTAL-L)
                          (tronco-y p) (tronco-dir p))) alop))

;; move-tartarugas: [List-of tartaruga] -> [List-of tartaruga]
(check-expect (move-tartarugas lot2) (list (make-tartaruga 1 23 "left")))
(check-expect (move-tartarugas (list (make-tartaruga -2 23 "left")))
              (list (make-tartaruga 81 23 "left")))
(define (move-tartarugas alot)
  ;; [tartaruga -> tartaruga] [List-of tartaruga] -> [List-of tartaruga]
  (map (λ (t) (make-tartaruga (move-left (tartaruga-x t) T-L T-TOTAL-L)
                           (tartaruga-y t) (tartaruga-dir t))) alot))

;; ride-move: jogador [List-of tronco] [List-of tartarugas] -> tronco
;; move the frg if it rides on a tronco or a tartaruga
(check-expect (ride-move jogador0 lotr2 lot2) jogador0)
(check-expect (ride-move (make-jogador -2 28 "up") lotr2 lot2)
              (make-jogador -1 28 "up"))
(check-expect (ride-move (make-jogador 2 23 "up") lotr2 lot2)
              (make-jogador 1 23 "up"))
(define (ride-move ap alop alot)
  (cond [(on-any-p? ap alop)
         (make-jogador (move-right (jogador-x ap) F-TAMANHO MAX-X)
                      (jogador-y ap) (jogador-dir ap))]
        [(on-any-t? ap alot)
         (make-jogador (move-left (jogador-x ap) F-TAMANHO MAX-X)
                      (jogador-y ap) (jogador-dir ap))]
        [else ap]))

;; on-any-p?: jogador [List-of tronco] -> Boolean
;; is the jogador on any tronco?
;; (is the center of jogador within any tronco image?)
(check-expect (on-any-p? jogador0 lotr2) #false)
(check-expect (on-any-p? (make-jogador -2 28 "up") lotr2) #true)
(define (on-any-p? ap alop)
  ;; [tronco -> Boolean] [List-of tronco] -> [List-of tronco]
  (ormap (λ (p) (on? ap (tronco-x p) (tronco-y p) TR-LARGURA TR-ALTURA)) alop))

;; on-any-t?: jogador [List-of tartaruga] -> Boolean
;; is the jogador on any tartaruga?
;; (is the center of jogador within any tartaruga image?)
(check-expect (on-any-t? jogador0 lot2) #false)
(check-expect (on-any-t? (make-jogador 2 23 "up") lot2) #true)
(define (on-any-t? ap alot)
  ;; [tartaruga -> Boolean] [List-of tartaruga] -> [List-of tartaruga]
  (ormap (λ (t) (on? ap (tartaruga-x t) (tartaruga-y t) T-L T-L)) alot))

;; on?: jogador Number Number NonNegReal NonNegReal -> Boolean
;; is the jogador within x-range and y-range of x-position and y-position?
(check-expect (on? jogador0 35 61 3 3) #false)
(check-expect (on? jogador0 35 61 4 4) #true)
(define (on? ap x-position y-position x-range y-range)
  (and (in-range? (jogador-x ap) x-position (/ (+ x-range 1) 2))
       (in-range? (jogador-y ap) y-position (/ (+ y-range 1) 2))))

;; in-range?: Number Number Number -> Boolean
;; is n1 within range of n2?
(check-expect (in-range? 3 8 4) #false)
(check-expect (in-range? 3 8 6) #true)
(define (in-range? n1 n2 range)
  (and (< n1 (+ n2 range))
       (> n1 (- n2 range))))

;; change-score: Score -> Score
;; deduct one from score on each tick
(check-expect (change-score PONTUACAO-INICIAL) 499)
(define (change-score score)
  (- score 1))



;;; Key-handler

;; move-world-jogador: World Direction -> World
;; change the position of the jogador in the given world when a key is pressed
(check-expect (move-world-jogador MUNDO0 "up")
              (make-world (make-jogador 37 58 "up") ldc1 lotr1 ldt1 info0))
(check-expect (move-world-jogador MUNDO0 "down")
              (make-world (make-jogador 37 68 "down") ldc1 lotr1 ldt1 info0))
(check-expect (move-world-jogador MUNDO0 "left")
              (make-world (make-jogador 32 63 "left") ldc1 lotr1 ldt1 info0))
(check-expect (move-world-jogador MUNDO0 "right")
              (make-world (make-jogador 42 63 "right") ldc1 lotr1 ldt1 info0))
(define (move-world-jogador aw adir)
  (make-world (move-jogador (world-jogador aw) adir)
              (world-carros aw)
              (world-troncos aw)
              (world-tartarugas aw)
              (world-info aw)))

;; move-jogador: jogador Direction -> jogador
;; change the position of the given jogador when a key is pressed
(check-expect (move-jogador jogador0 "up") (make-jogador 37 58 "up"))
(check-expect (move-jogador jogador0 "down") (make-jogador 37 68 "down"))
(check-expect (move-jogador jogador0 "left") (make-jogador 32 63 "left"))     
(check-expect (move-jogador jogador0 "right") (make-jogador 42 63 "right"))
(define (move-jogador ap adir)
  (cond [(string=? adir "up")
         (make-jogador (jogador-x ap) (- (jogador-y ap) FROG-PASSO) adir)]
        [(string=? adir "down")
         (make-jogador (jogador-x ap) (above-bottom (jogador-y ap)) adir)]
        [(string=? adir "left")
         (make-jogador (- (jogador-x ap) FROG-PASSO) (jogador-y ap) adir)]
        [(string=? adir "right")
         (make-jogador (+ (jogador-x ap) FROG-PASSO) (jogador-y ap) adir)]))

;; above-bottom: Number -> Number
;; add one step (5 grids) to y if it remains above the bottom of the screen,
;; otherwise keep y
(check-expect (above-bottom 10) 15)
(check-expect (above-bottom 68) 68)
(define (above-bottom y)
  (if (<= (+ y FROG-PASSO) (- MAX-Y (/ F-TAMANHO 2)))
      (+ y FROG-PASSO)
      y))



;;; Status detection

;; end?: World -> Boolean
;; does the game over?
(check-expect (end? MUNDO0) #false)
(check-expect (end? (make-world jogador0 ldc1 lotr1 ldt1 (make-info 1000 0)))
              #true)
(check-expect (end? (make-world jogador0 ldc1 lotr1 ldt1 (make-info 0 1)))
              #true)
(define (end? aw)
  (or (<= (info-lives (world-info aw)) 0)
      (<= (info-score (world-info aw)) 0)
      (win? (world-jogador aw))))

;; reset-world: World -> World
(check-expect (reset-world MUNDO0)
              (make-world jogador0 ldc1 lotr1 ldt1 (make-info 400 2)))
(define (reset-world aw)
  (make-world jogador0 ldc1 lotr1 ldt1
              (make-info (- (info-score (world-info aw)) 100)
                         (- (info-lives (world-info aw)) 1))))

;; dead?: World -> Boolean
;; does current jogador dead?
(check-expect (dead? (make-world (make-jogador 4 58 "up") ldc1 lotr1 ldt1 info0))
              #true)
(check-expect (dead? (make-world (make-jogador 31 28 "up") ldc1 lotr1 ldt1 info0))
              #true)
(check-expect (dead? (make-world (make-jogador 0 28 "up") ldc1 lotr1 ldt1 info0))
              #true)
(check-expect (dead? (make-world jogador0 ldc1 lotr1 ldt1 (make-info 0 3)))
              #true)
(check-expect (dead? MUNDO0) #false)
(define (dead? aw)
  (or (hit? (world-jogador aw) (world-carros aw))
      (sink? (world-jogador aw) (world-troncos aw) (world-tartarugas aw))
      (out? (world-jogador aw))
      (<= (info-score (world-info aw)) 0)))

;; hit?: jogador [List-of carro] -> Boolean
;; is the jogador hit by any carro?
(check-expect (hit? (make-jogador 4 58 "up") ldc1) #true)
(check-expect (hit? (make-jogador 2 53 "up") ldc1) #true)
(check-expect (hit? jogador0 ldc1) #false)
(define (hit? ap alov)
  ;; [carro -> Boolean] [List-of carro] -> Boolean 
  (ormap (λ (v) (on? ap (carro-x v) (carro-y v)
                     (sub1 (+ C-LARGURA F-TAMANHO))
                     (sub1 (+ C-ALTURA F-TAMANHO))))
         alov))

;; sink?: jogador [List-of tronco] [List-of tartaruga] -> Boolean
;; is the jogador sink in the river?
(check-expect (sink? (make-jogador 10 28 "up") lotr1 ldt1) #true)
(check-expect (sink? (make-jogador 20 23 "up") lotr1 ldt1) #true)
(check-expect (sink? (make-jogador 20 28 "up") lotr1 ldt1) #false)
(define (sink? ap alop alot)
  (and (in-river? ap)
       (not (on-any-p? ap alop))
       (not (on-any-t? ap alot))))

;; in-river?: jogador -> Boolean
;; is the jogador in the river area?
(check-expect (in-river? (make-jogador 10 28 "up")) #true)
(check-expect (in-river? jogador0) #false)
(define (in-river? ap)
  (and (> (jogador-y ap) MIN-RIO)
       (< (jogador-y ap) MAX-RIO)))

;; out?: jogador -> Boolean
;; is the jogador out of left or right boundary?
(define (out? ap)
  (or (> (jogador-x ap) (- MAX-X (/ F-TAMANHO 2)))
      (< (jogador-x ap) (/ F-TAMANHO 2))))

;; win?: jogador -> Boolean
;; does the jogador win the game?
(check-expect (win? (make-jogador 40 3 "up")) #true)
(check-expect (win? jogador0) #false)
(define (win? ap)
  (<= (jogador-y ap) (+ (/ F-TAMANHO 2) 1)))

;; show-end: World -> Image
;; show the game-over image
(check-expect (show-end (make-world (make-jogador 40 3 "up")
                                    ldc1 lotr1 ldt1 (make-info 300 2)))
              (place-image (text "Score: 300" 40 'green) 370 400 WIN))
(check-expect (show-end (make-world jogador0 ldc1 lotr1 ldt1 (make-info 0 1)))
              GAME-OVER)
(define (show-end aw)
  (cond [(win? (world-jogador aw))
         (place-image (text
                       (string-append "Score: "
                                      (number->string
                                       (info-score (world-info aw))))
                       40 'green) 370 400 WIN)]
        [else GAME-OVER]))



;;;; ---------------------------------------------------------------------------
;;;; LAUNCH THE GAME

;;; World -> World
;; launch the game
(big-bang MUNDO0
          [to-draw draw-all]
          [on-tick move-all (/ 1 DIFICULDADE)]
          [on-key move-world-jogador]
          [stop-when end? show-end])

