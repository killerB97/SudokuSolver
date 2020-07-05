import numpy as np
import operator
import tensorflow as tf
from operator import itemgetter
import cv2
import math
import Model
import copy

class Sudoku:

  def __init__(self):
      self.sudoku = [[] for _ in range(9)]
      self.threshold = []
      self.output = None

  def threshImg(self,thresh,img):
      self.output = cv2.adaptiveThreshold(img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, thresh, 2)

  def refine(self):
      avg = sum(self.threshold)/len(self.threshold) 
      num_avg = [n for n,thresh in enumerate(self.threshold) if thresh<=avg]
      row = 0
      for index in num_avg:
          row = math.floor(index/9)
          self.sudoku[row][index%9] = 0

 

class SudoSolver:

  def __init__(self):
      self.answer = None

  def __init__(self,model):
      self.model = model  

  def dist(self,p1, p2):

      a = p2[0] - p1[0]
      b = p2[1] - p1[1]
      return np.sqrt((a ** 2) + (b ** 2))

  def wrap_img(self,dil,pts):

      points1 = np.float32([pts])
      size = int(max(self.dist(pts[0],pts[1]),self.dist(pts[0],pts[2]), self.dist(pts[2],pts[3]), self.dist(pts[3],pts[0])))
      points2 = np.float32([[0,size],[size,size],[size,0],[0,0]])
      matrix = cv2.getPerspectiveTransform(points1,points2)
      output = cv2.warpPerspective(dil,matrix,(size,size))
      return size,output

  def check_empty(self,output,threshold):
    thresh = np.sum(output)
    threshold.append(thresh)

  def imgProcessing(self,img):
      blur_img = cv2.GaussianBlur(img.copy(), (13, 13), 0)

      # Binary adaptive threshold using 9 nearest neighbour pixels
      thresh = cv2.adaptiveThreshold(blur_img, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY_INV, 7, 2)

      kernel = np.ones((3, 3))
      dilate = cv2.dilate(thresh, kernel)

      return dilate


  def cut_from_rect(self,img, rect):
    """Cuts a rectangle from an image using the top left and bottom right points."""
    return img[int(rect[0][1]):int(rect[1][1]), int(rect[0][0]):int(rect[1][0])]

  def scale_and_centre(self,img, size, margin=0, background=0):
    """Scales and centres an image onto a new background square."""
    h, w = img.shape[:2]

    def centre_pad(length):
        """Handles centering for a given length that may be odd or even."""
        if length % 2 == 0:
            side1 = int((size - length) / 2)
            side2 = side1
        else:
            side1 = int((size - length) / 2)
            side2 = side1 + 1
        return side1, side2

    def scale(r, x):
        return int(r * x)

    if h > w:
        t_pad = int(margin / 2)
        b_pad = t_pad
        ratio = (size - margin) / h
        w, h = scale(ratio, w), scale(ratio, h)
        l_pad, r_pad = centre_pad(w)
    else:
        l_pad = int(margin / 2)
        r_pad = l_pad
        ratio = (size - margin) / w
        w, h = scale(ratio, w), scale(ratio, h)
        t_pad, b_pad = centre_pad(h)

    img = cv2.resize(img, (w, h))
    img = cv2.copyMakeBorder(img, t_pad, b_pad, l_pad, r_pad, cv2.BORDER_CONSTANT, None, background)
    return cv2.resize(img, (size, size))

  def find_largest_feature(self,inp_img, scan_tl=None, scan_br=None):
    """
    Uses the fact the `floodFill` function returns a bounding box of the area it filled to find the biggest
    connected pixel structure in the image. Fills this structure in white, reducing the rest to black.
    """
    img = inp_img.copy()  # Copy the image, leaving the original untouched
    height, width = img.shape[:2]

    max_area = 0
    seed_point = (None, None)

    if scan_tl is None:
        scan_tl = [0, 0]

    if scan_br is None:
        scan_br = [width, height]

    # Loop through the image
    for x in range(scan_tl[0], scan_br[0]):
        for y in range(scan_tl[1], scan_br[1]):
            # Only operate on light or white squares
            if img.item(y, x) == 255 and x < width and y < height:  # Note that .item() appears to take input as y, x
                area = cv2.floodFill(img, None, (x, y), 64)
                if area[0] > max_area:  # Gets the maximum bound area which should be the grid
                    max_area = area[0]
                    seed_point = (x, y)

    # Colour everything grey (compensates for features outside of our middle scanning range
    for x in range(width):
        for y in range(height):
            if img.item(y, x) == 255 and x < width and y < height:
                cv2.floodFill(img, None, (x, y), 64)

    mask = np.zeros((height + 2, width + 2), np.uint8)  # Mask that is 2 pixels bigger than the image

    # Highlight the main feature
    if all([p is not None for p in seed_point]):
        cv2.floodFill(img, mask, seed_point, 255)

    top, bottom, left, right = height, 0, width, 0

    for x in range(width):
        for y in range(height):
            if img.item(y, x) == 64:  # Hide anything that isn't the main feature
                cv2.floodFill(img, mask, (x, y), 0)

            # Find the bounding parameters
            if img.item(y, x) == 255:
                top = y if y < top else top
                bottom = y if y > bottom else bottom
                left = x if x < left else left
                right = x if x > right else right

    bbox = [[left, top], [right, bottom]]
    return img, np.array(bbox, dtype='float32'), seed_point

  def warp_box_ocr(self,dil,start,size,end,factor,index,sudoku,threshold):
      points1 = np.float32([[start,factor*size],[start+size,factor*size],[start+size,end],[start,end]])
      points2 = np.float32([[0,size],[size,size],[size,0],[0,0]])
      matrix = cv2.getPerspectiveTransform(points1,points2)
      output = cv2.warpPerspective(dil,matrix,(size,size))
      
      h, w = output.shape[:2]
      size = output.shape[:2][0]
      margin = int(np.mean([h, w]) / 2.5)
      _,bbox,seed = self.find_largest_feature(output,[margin, margin], [w - margin, h - margin])
      output = self.cut_from_rect(output, bbox)
        # Scale and pad the digit so that it fits a square of the digit size we're using for machine learning
      
      w = bbox[1][0] - bbox[0][0]
      h = bbox[1][1] - bbox[0][1]

        # Ignore any small bounding boxes
      if w > 0 and h > 0 and (w * h) > (size*size)//(size*0.5) and len(output) > 0:
        output =  self.scale_and_centre(output, size, size//2)
        output = cv2.resize(output, (28,28), interpolation = cv2.INTER_AREA)
      else:
        output =  np.zeros((28,28), np.uint8)
      
      # Predict digit within bounding box after removal of small bounding boxes
      pred = self.model.predict(output.reshape(1, 28, 28, 1))
      self.check_empty(output,threshold)
      if pred.argmax()==10:
        # Append prediction to sudoku list representation used for solving
        sudoku[index].append(0)
      else:
        sudoku[index].append(int(pred.argmax()))

      
  def get_boards(self,board):

      colboard = list(map(list, zip(*board)))
      boxboard = [[] for _ in range(len(board))]
      row = 0
      boxCol = 0
      boxRow = 0
      while row<9:
          for i in range(3):
              for j in range(3):
                  boxboard[row].append(board[i+boxRow][j+boxCol])
          row+=1
          boxCol+=3
          if row%3==0:
              boxCol =0
              boxRow+=3
      return colboard,boxboard

  def sqr(self,row,col):
      return math.floor(row/3)*3 + math.floor(col/3)

  def sqc(self,row,col):
      return (row%3)*3 + (col%3)

  def find(self,board):
      for row in range(len(board)):
          for col in range(len(board[0])):
              if board[row][col]==0:
                  return row,col
      return None

  def sudokuSolver(self,board,boxboard,colboard):

      if not self.find(board):
          return True
      else:
          row,j = self.find(board)
      sqrow = self.sqr(row,j)
      sqcol = self.sqc(row,j)
      for k in range(1,10):
          if (k not in board[row]) and (k not in colboard[j]) and (k not in boxboard[sqrow]):
              board[row][j] = k
              colboard[j][row] = k
              boxboard[sqrow][sqcol] = k
              if self.sudokuSolver(board,boxboard,colboard):
                  return True
              board[row][j] = 0
              colboard[j][row] = 0
              boxboard[sqrow][sqcol] = 0


      return False


  def writeToBoard(self,output,sudoku,orig,size):
      x_coord = 0
      sudoIndex = 0
      factor = 1
      y_coord = 0
      size = int(size/9)
      font = cv2.FONT_HERSHEY_COMPLEX

      for grid in range(81):
          if grid%9==0 and grid!=0:
              y_coord+=size
              x_coord=0
              factor+=1
              sudoIndex+=1

          if orig[sudoIndex][grid%9]!=0:
              x_coord+=size
              continue

          else:
              coord = (int((2*x_coord+size)//2.05),int((y_coord+factor*size)//1.95))
              cv2.putText(output,str(sudoku[sudoIndex][grid%9]),coord,font,size*0.014,(130, 0, 75),1,cv2.LINE_AA)
          x_coord+=size

      return output

  def findSudokuBox(self,img):
      
      # Finding all contours within the image
      ctrs, hier = cv2.findContours(img.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

      contours = sorted(ctrs, key=cv2.contourArea, reverse=True)  # Sort by area, descending
      polygon = contours[0]
        
      # Find four corner pints of Sudoku puzzle from the Image
      bottom_right = polygon[max(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      top_left = polygon[min(enumerate([pt[0][0] + pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      bottom_left = polygon[min(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      top_right = polygon[max(enumerate([pt[0][0] - pt[0][1] for pt in polygon]), key=itemgetter(1))[0]][0]
      pts = [bottom_left, bottom_right, top_right, top_left]

      return pts

  def extractDigits(self,size,solutions):
      x_coord = 0
      factor = 1
      y_coord = 0
      size = int(size / 9)
      sudoIndex = 0
      for grid in range(81):
          if grid % 9 == 0 and grid != 0:
              y_coord += size
              x_coord = 0
              factor += 1
              sudoIndex += 1
          for sudokuInstance in solutions:
            self.warp_box_ocr(sudokuInstance.output.copy(), x_coord, size, y_coord, factor, sudoIndex, sudokuInstance.sudoku, sudokuInstance.threshold)
          x_coord += size

  def notInRow(self,arr, row):  
  
    # Set to store characters seen so far.  
    st = set()  
  
    for i in range(0, 9):  
  
        # If already encountered before,  
        # return false  
        if arr[row][i] in st:  
            return False
  
        # If it is not an empty cell, insert value  
        # at the current cell in the set  
        if arr[row][i] != 0:  
            st.add(arr[row][i])  
      
    return True
  
# Checks whether there is any  
# duplicate in current column or not.  
  def notInCol(self,arr, col):  

    st = set()  

    for i in range(0, 9):  

        # If already encountered before, 
        # return false  
        if arr[i][col] in st: 
            return False

        # If it is not an empty cell, insert  
        # value at the current cell in the set  
        if arr[i][col] != 0:  
            st.add(arr[i][col])  
    
    return True

# Checks whether there is any duplicate  
# in current 3x3 box or not.  
  def notInBox(self,arr, startRow, startCol):  

    st = set()  

    for row in range(0, 3):  
        for col in range(0, 3):  
            curr = arr[row + startRow][col + startCol]  

            # If already encountered before,  
            # return false  
            if curr in st:  
                return False

            # If it is not an empty cell,  
            # insert value at current cell in set  
            if curr != 0:  
                st.add(curr)  
        
    return True

# Checks whether current row and current  
# column and current 3x3 box is valid or not  
  def isValid(self,arr, row, col):  

    return (self.notInRow(arr, row) and self.notInCol(arr, col) and
            self.notInBox(arr, row - row % 3, col - col % 3))  

  def isValidConfig(self,arr, n):  

    for i in range(0, n):  
        for j in range(0, n):  

            # If current row or current column or  
            # current 3x3 box is not valid, return false  
            if not self.isValid(arr, i, j):  
                return False


  def Solve(self,img):
      grey_img = cv2.cvtColor(img.copy(), cv2.COLOR_BGR2GRAY)
      color_img = img

      preProcessedImg = self.imgProcessing(grey_img)

      puzzleCorners = self.findSudokuBox(preProcessedImg)

      size, croppedImg = self.wrap_img(grey_img.copy(), puzzleCorners)
      
      # Identifying optimal threshold filter size and Gaussian Blur filter size based on size of image
      thresh_lvl = croppedImg.shape[0]//50
      blur_lvl = croppedImg.shape[0]//40
  
      thresh_lvl += 1 if thresh_lvl%2==0 else 0
      blur_lvl += 1 if blur_lvl%2==0 else 0

      croppedImg = cv2.GaussianBlur(croppedImg.copy(), (blur_lvl, blur_lvl), 0)
      
      # owing to inconsistency of outputs based on threshold filter sizes, I propose to investigate three different thresh values based on heuristics to get the best possible output
      lowerEnd = thresh_lvl-6
      if thresh_lvl-6<=1:
          lowerEnd = 3

      depthThresh = [thresh_lvl, thresh_lvl+6, lowerEnd]

      sudoku1 = Sudoku()
      sudoku2 = Sudoku()
      sudoku3 = Sudoku()

      solutions = [sudoku1,sudoku2,sudoku3]
      
      for sudoku,thresh_lvl in zip(solutions,depthThresh):
          sudoku.threshImg(thresh_lvl,croppedImg.copy())

      print('Thresh Levels adjusted')
      
      self.extractDigits(size,solutions)
      
      index = 0
      
      foundSolution = False
      for n,sudoInstance in enumerate(solutions):
        sudoInstance.refine()
        if self.isValidConfig(sudoInstance.sudoku,9)==False:
            continue
        orig_sudoku = copy.deepcopy(sudoInstance.sudoku)
        colboard, boxboard = self.get_boards(sudoInstance.sudoku)
        self.sudokuSolver(sudoInstance.sudoku, boxboard, colboard)
        if sudoInstance.sudoku==orig_sudoku:
            continue
        else:
            foundSolution = True
            index = n
            break
      
      if foundSolution:
        sizeFinal, finalAnswerImg = self.wrap_img(color_img.copy(), puzzleCorners)
        final_img = self.writeToBoard(finalAnswerImg.copy(), solutions[index].sudoku, orig_sudoku, sizeFinal)
        return foundSolution,final_img,''
      else:
          return foundSolution, solutions[0].sudoku, color_img

  def reSolve(self,sudoku,img):
        grey_img = cv2.cvtColor(img.copy(), cv2.COLOR_BGR2GRAY)
        preProcessedImg = self.imgProcessing(grey_img)
        puzzleCorners = self.findSudokuBox(preProcessedImg)
        orig_sudoku = copy.deepcopy(sudoku)
        colboard, boxboard = self.get_boards(sudoku)
        self.sudokuSolver(sudoku, boxboard, colboard)
        print(sudoku)        
        sizeFinal, finalAnswerImg = self.wrap_img(img.copy(), puzzleCorners)
        final_img = self.writeToBoard(finalAnswerImg.copy(), sudoku, orig_sudoku, sizeFinal)
        return final_img

    # Link with Android app
