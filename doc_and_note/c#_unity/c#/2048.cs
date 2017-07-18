using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace _2048
{
    class Cube { 
        public Cube()
        {
            x = 0;
            y = 0;
            cube_score = 0;
        }
        public Cube(int m, int n, int score)
        {
            x = m;
            y = n;
            cube_score = score;
        }
        public int getx()
        {
            return x;
        }

        public void set_x(int pointx)
        {
            x = pointx;
        }
        public int gety()
        {
            return y;
        }
        public void set_y(int pointy)
        {
            y = pointy;
        }
        public int getscore() 
        {
            return cube_score;
        }
        public void set_score(int pointscore)
        {
            cube_score = pointscore;
        }
        public bool isempty()
        {
            if (x == 0 && y == 0 && cube_score == 0)
                return true;
            return false;
        }
        private int x = 0;
        private int y = 0;
        private int cube_score = 0;
    };

    class Gameobj {
        public Gameobj()
        {
            cubelist = new Cube[16];
            for (int i = 0; i < 16; i++)
                cubelist[i] = new Cube();
        }
        public void initGameobj()
        {
            for (int i = 0; i < 16; i++)
            {
                cubelist[i].set_x((i) % 4);
                cubelist[i].set_y((i) / 4);
            }
        }

        public void showCubes()
        { 
            for(int i = 0; i < 16; i++){
                int x = cubelist[i].getx();
                int y = cubelist[i].gety();
                int score = cubelist[i].getscore();
                Console.Write( x +"|"+y+"|"+score+ "\t");
                if ((i+1) % 4 == 0 && i != 0)
                    Console.WriteLine("");
            }
        }
        private Cube[] cubelist;
        private int count = 0;
    };

    class Program
    {
        static void Main(string[] args)
        {

            Gameobj game = new Gameobj();
            game.initGameobj();
            game.showCubes();
            int[,] arr = new int[4, 4]{
                                                {8,64,2,32},
                                                 {2,0,2,2},
                                                 {0,4,32,2},
                                                 {4,0,16,0},
                                             };
            for (int a = 0; a < 5; a++)
            {
                if (a == 1)
                    arr = YiDong(arr); 
                else if (a==2)
                    arr = YiDong1(arr);
                else if (a == 3)
                    arr = YiDong2(arr);
                else if (a == 4)
                    arr = YiDong3(arr); 
                for (int i = 0; i < 4; i++)
                {
                    for (int j = 0; j < 4; j++)
                    {
                        Console.Write(arr[i, j] + "\t");
                    }
                    Console.WriteLine();
                }
                Console.WriteLine("**********************************************************");
            }
            Console.ReadLine();
        }
        private static  int[] QuLing (int[] arr)
        {
            int[] arr1;
            arr1 = new int[4];
            int j = 0;
            for (int i = 0; i < 4;i++)
            {
                if (arr[i] != 0)
                {
                    arr1[j] = arr[i];
                    j++;
                }
            }
                return arr1;
        }
         private static  int[] HeBing (int[] arr)
        {
            arr = QuLing(arr);
            for (int i = 0; i < 3; i++)
            {
                if (arr[i] == arr[i+1])
                {
                    arr[i] = arr[i] * 2;
                    arr[i + 1] = 0;
                }
            }
            arr = QuLing(arr);
            return arr;
        }
        //向上移动
        private static  int[,] YiDong (int[,] arr)
         {
            int[]arr1;
            arr1=new int[4];
            for(int j=0;j<4;j++)
            {
                for (int i= 0; i< 4; i++)
                {
                    arr1[i] = arr[i, j];
                }
                arr1 = HeBing(arr1);
                for (int i = 0; i < 4; i++)
                {
                    arr[i, j] = arr1[i];
                }
            }
            return arr;
         }
        //向下移动
        private static int[,] YiDong1(int[,] arr)
        {
            int[] arr1;
            int a = 0;
            arr1 = new int[4];
            for (int j = 0; j < 4; j++)
            {
                a = 0;
                for (int i = 3; i >=0; i--)
                {
                    arr1[a] = arr[i, j];
                    a++;
                }
                arr1 = HeBing(arr1);
                a = 0;
                for (int i = 3; i >=0; i--)
                {
                    arr[i, j] = arr1[a];
                    a++;
                }
            }
            return arr;
        }
       //向右移动
        private static int[,] YiDong2(int[,] arr)
        {
            int[] arr1;
            int a;
            arr1 = new int[4];
            for (int j = 0; j < 4; j++)
            {
                a = 0;
                for (int i = 3; i >= 0; i--)
                {
                    arr1[a] = arr[j, i];
                    a++;
                }
                arr1 = HeBing(arr1);
                a = 0;
                for (int i = 3; i>=0; i--)
                {
                    arr[j, i] = arr1[a];
                    a++;
                }
            }
            return arr;
        }
        private static int[,] YiDong3(int[,] arr)
        {
            int[] arr1;
            arr1 = new int[4];
            for (int j = 0; j < 4; j++)
            {
                for (int i = 0; i < 4; i++)
                {
                    arr1[i] = arr[j, i];
                }
                arr1 = HeBing(arr1);
                for (int i = 0; i < 4; i++)
                {
                    arr[j, i] = arr1[i];
                }
            }
            return arr;
        }
    }
}
