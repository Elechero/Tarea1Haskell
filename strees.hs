data SuffixTree = Leaf Int
				| Node [(String, SuffixTree)]
				deriving(Eq,Ord,Show)

-- | 'isPrefix' recibe dos Strings s0 y s1 y retorna True si s0 es prefijo de s1, False
-- caso contrario.
isPrefix ::  String -> String -> Bool
isPrefix   []      _   = True
isPrefix    _     []   = False
isPrefix (p:ps) (s:ss) = p == s && (isPrefix ps ss)

-- | 'removePrefix' recibe dos Strings p y s y retorna un nuevo String resultante de
-- extraer p de s.
removePrefix :: String -> String -> String
removePrefix p s =  if isPrefix p s then drop (length p) s 
					else s

-- | 'suffixes' recibe una lista de elementos y retorna una lista con todos los sufijos
-- de la lista.
suffixes :: [a] -> [[a]]
suffixes s = scanr (:) [] s

-- | 'isSubstring' recibe dos Strings s1 y s2 y retorna True si s1 es un substring de s2.
-- False en caso contrario.
isSubstring :: String -> String -> Bool
isSubstring s1 s2 = any (isPrefix s1) (suffixes s2)

-- | 'findSubstrings' recibe dos Strings s1 y s2 y retorna una lista de enteros
-- con la posición de todas las ocurrencias de s1 en s2.
findSubstrings :: String -> String -> [Int]
findSubstrings s1 s2 = [ n | (n,x) <-zip [0..] (map (isPrefix s1) (suffixes s2)), x ] 

--Segunda Parte

-- | 'getIndices' recibe un árbol de sufijos y devuelve todos los valores almacenados en las
-- hojas del arbol.
getIndices :: SuffixTree -> [Int]
getIndices (Leaf a) = [a]
getIndices (Node st )= foldl obtHoja [] st
						where
							obtHoja l (_,Leaf x) = x:l
							obtHoja l (_,Node t) = foldl obtHoja l t
-- | 'findsubstrings' recibe un String, un árbol de sufijos y retorna una lista de enteros con
-- los indices de todas las ocurrencias del string en el árbol.
findSubstrings' :: String -> SuffixTree -> [Int]
findSubstrings' s (Leaf _)  = []
findSubstrings' s (Node st) 
				| st == [] = []
				| isPrefix s a = getIndices nodo 
				| isPrefix a s = findSubstrings' (removePrefix a s) nodo
				| otherwise = findSubstrings' s $ Node $ tail st
				where
					a = fst $ head st
					nodo = snd $ head st

-- | 'isLeaf' recibe una tupla con un elemento y un árbol de sufijos.
isLeaf :: (a,SuffixTree) -> Bool
isLeaf (_,Leaf _) = True
isLeaf (_,_)      = False

-- | 'insert' permite insertar un nuevo sufijo en el arbol. 
insert :: (String,Int) -> SuffixTree -> SuffixTree
insert (s,i) (Leaf _) = error "Agregando en hojas"
insert (s,i) (Node a) = if mismoPre == [] then Node ((s,Leaf i):a)
						else
							if isLeaf found then 
								Node (map replace a)
							else
								if resto /= [] then	
									Node (map push a)
								else 
									Node (map seguir a)
	where
		comunes [] _ = []
		comunes _ [] = []
		comunes (s1:ss1) (s2:ss2) = if s1 == s2 then s1:(comunes ss1 ss2)
									else []
		mismoPre = [ n | n <- a, fst n /= "",(head.fst) n == head s ]
		found = head mismoPre
		comun = comunes s (fst found)
		diff = removePrefix (comunes s (fst found)) s
		resto = removePrefix (comunes s (fst found)) (fst found)
		replace e = if found == e then (comun,Node [(resto,snd found),(diff, Leaf i)])
					else e
		push e = if found == e then (comun,Node[(resto,snd found),(diff,Leaf i)])
				 else e
		seguir e = if e == found then (fst e,insert (diff,i) (snd found))
				   else e

-- | 'buildTree' genera un árbol de sufijos a partir de un string. 
buildTree :: String -> SuffixTree
buildTree s = foldl (flip insert) (Node []) $ reverse $ zip (init $ suffixes s) [0..]

-- | 'longestRepeatedsubstring' Recibe un árbol de sufijos y retorna una lista que contiene
-- los subStrings repetidos más largos.
longestRepeatedSubstring :: SuffixTree -> [String]
longestRepeatedSubstring (Leaf _)   = []
longestRepeatedSubstring (Node st ) = fst $ foldl look ([],[]) st
	where
		look (lrss,path) (_,Leaf _) = (lrss,path)
		look (lrss,path) (l,Node t)
			| lrss == [] = (fst $ foldl look ([l],l) t,path)
			| lrss /= [] = 
				if length (head lrss) < (length $ path ++ l) then
					(fst $ foldl look ([path ++ l],path ++ l) t , path)
				else
					if length (head lrss) == (length $ path ++ l) then
						(fst $ foldl look ((path ++ l):lrss,path ++ l) t,path)
					else
						(fst $ foldl look (lrss,path ++ l) t,path)
