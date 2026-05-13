; ModuleID = 'target_ctaes.c'
source_filename = "target_ctaes.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local void @LoadBytes(ptr nocapture noundef writeonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #0 {
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 2 dereferenceable(16) %0, i8 0, i64 16, i1 false)
  %3 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 1
  %4 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 2
  %5 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 3
  %6 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 4
  %7 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 5
  %8 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 6
  %9 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 7
  br label %10

10:                                               ; preds = %2, %10
  %11 = phi i32 [ 0, %2 ], [ %216, %10 ]
  %12 = phi ptr [ %1, %2 ], [ %167, %10 ]
  %13 = phi i16 [ 0, %2 ], [ %174, %10 ]
  %14 = phi i16 [ 0, %2 ], [ %180, %10 ]
  %15 = phi i16 [ 0, %2 ], [ %186, %10 ]
  %16 = phi i16 [ 0, %2 ], [ %192, %10 ]
  %17 = phi i16 [ 0, %2 ], [ %198, %10 ]
  %18 = phi i16 [ 0, %2 ], [ %204, %10 ]
  %19 = phi i16 [ 0, %2 ], [ %210, %10 ]
  %20 = phi i16 [ 0, %2 ], [ %215, %10 ]
  %21 = getelementptr inbounds i8, ptr %12, i64 1
  %22 = load i8, ptr %12, align 1, !tbaa !5
  %23 = and i8 %22, 1
  %24 = zext i8 %23 to i32
  %25 = shl nuw i32 %24, %11
  %26 = trunc i32 %25 to i16
  %27 = or i16 %13, %26
  store i16 %27, ptr %0, align 2, !tbaa !8
  %28 = lshr i8 %22, 1
  %29 = and i8 %28, 1
  %30 = zext i8 %29 to i32
  %31 = shl nuw i32 %30, %11
  %32 = trunc i32 %31 to i16
  %33 = or i16 %14, %32
  store i16 %33, ptr %3, align 2, !tbaa !8
  %34 = lshr i8 %22, 2
  %35 = and i8 %34, 1
  %36 = zext i8 %35 to i32
  %37 = shl nuw i32 %36, %11
  %38 = trunc i32 %37 to i16
  %39 = or i16 %15, %38
  store i16 %39, ptr %4, align 2, !tbaa !8
  %40 = lshr i8 %22, 3
  %41 = and i8 %40, 1
  %42 = zext i8 %41 to i32
  %43 = shl nuw i32 %42, %11
  %44 = trunc i32 %43 to i16
  %45 = or i16 %16, %44
  store i16 %45, ptr %5, align 2, !tbaa !8
  %46 = lshr i8 %22, 4
  %47 = and i8 %46, 1
  %48 = zext i8 %47 to i32
  %49 = shl nuw i32 %48, %11
  %50 = trunc i32 %49 to i16
  %51 = or i16 %17, %50
  store i16 %51, ptr %6, align 2, !tbaa !8
  %52 = lshr i8 %22, 5
  %53 = and i8 %52, 1
  %54 = zext i8 %53 to i32
  %55 = shl nuw i32 %54, %11
  %56 = trunc i32 %55 to i16
  %57 = or i16 %18, %56
  store i16 %57, ptr %7, align 2, !tbaa !8
  %58 = lshr i8 %22, 6
  %59 = and i8 %58, 1
  %60 = zext i8 %59 to i32
  %61 = shl nuw i32 %60, %11
  %62 = trunc i32 %61 to i16
  %63 = or i16 %19, %62
  store i16 %63, ptr %8, align 2, !tbaa !8
  %64 = lshr i8 %22, 7
  %65 = zext i8 %64 to i32
  %66 = shl nuw i32 %65, %11
  %67 = trunc i32 %66 to i16
  %68 = or i16 %20, %67
  store i16 %68, ptr %9, align 2, !tbaa !8
  %69 = getelementptr inbounds i8, ptr %12, i64 2
  %70 = load i8, ptr %21, align 1, !tbaa !5
  %71 = add nuw nsw i32 %11, 4
  %72 = and i8 %70, 1
  %73 = zext i8 %72 to i32
  %74 = shl nuw i32 %73, %71
  %75 = trunc i32 %74 to i16
  %76 = or i16 %27, %75
  store i16 %76, ptr %0, align 2, !tbaa !8
  %77 = lshr i8 %70, 1
  %78 = and i8 %77, 1
  %79 = zext i8 %78 to i32
  %80 = shl nuw i32 %79, %71
  %81 = trunc i32 %80 to i16
  %82 = or i16 %33, %81
  store i16 %82, ptr %3, align 2, !tbaa !8
  %83 = lshr i8 %70, 2
  %84 = and i8 %83, 1
  %85 = zext i8 %84 to i32
  %86 = shl nuw i32 %85, %71
  %87 = trunc i32 %86 to i16
  %88 = or i16 %39, %87
  store i16 %88, ptr %4, align 2, !tbaa !8
  %89 = lshr i8 %70, 3
  %90 = and i8 %89, 1
  %91 = zext i8 %90 to i32
  %92 = shl nuw i32 %91, %71
  %93 = trunc i32 %92 to i16
  %94 = or i16 %45, %93
  store i16 %94, ptr %5, align 2, !tbaa !8
  %95 = lshr i8 %70, 4
  %96 = and i8 %95, 1
  %97 = zext i8 %96 to i32
  %98 = shl nuw i32 %97, %71
  %99 = trunc i32 %98 to i16
  %100 = or i16 %51, %99
  store i16 %100, ptr %6, align 2, !tbaa !8
  %101 = lshr i8 %70, 5
  %102 = and i8 %101, 1
  %103 = zext i8 %102 to i32
  %104 = shl nuw i32 %103, %71
  %105 = trunc i32 %104 to i16
  %106 = or i16 %57, %105
  store i16 %106, ptr %7, align 2, !tbaa !8
  %107 = lshr i8 %70, 6
  %108 = and i8 %107, 1
  %109 = zext i8 %108 to i32
  %110 = shl nuw i32 %109, %71
  %111 = trunc i32 %110 to i16
  %112 = or i16 %63, %111
  store i16 %112, ptr %8, align 2, !tbaa !8
  %113 = lshr i8 %70, 7
  %114 = zext i8 %113 to i32
  %115 = shl nuw i32 %114, %71
  %116 = trunc i32 %115 to i16
  %117 = or i16 %68, %116
  store i16 %117, ptr %9, align 2, !tbaa !8
  %118 = getelementptr inbounds i8, ptr %12, i64 3
  %119 = load i8, ptr %69, align 1, !tbaa !5
  %120 = add nuw nsw i32 %11, 8
  %121 = and i8 %119, 1
  %122 = zext i8 %121 to i32
  %123 = shl nuw i32 %122, %120
  %124 = trunc i32 %123 to i16
  %125 = or i16 %76, %124
  store i16 %125, ptr %0, align 2, !tbaa !8
  %126 = lshr i8 %119, 1
  %127 = and i8 %126, 1
  %128 = zext i8 %127 to i32
  %129 = shl nuw i32 %128, %120
  %130 = trunc i32 %129 to i16
  %131 = or i16 %82, %130
  store i16 %131, ptr %3, align 2, !tbaa !8
  %132 = lshr i8 %119, 2
  %133 = and i8 %132, 1
  %134 = zext i8 %133 to i32
  %135 = shl nuw i32 %134, %120
  %136 = trunc i32 %135 to i16
  %137 = or i16 %88, %136
  store i16 %137, ptr %4, align 2, !tbaa !8
  %138 = lshr i8 %119, 3
  %139 = and i8 %138, 1
  %140 = zext i8 %139 to i32
  %141 = shl nuw i32 %140, %120
  %142 = trunc i32 %141 to i16
  %143 = or i16 %94, %142
  store i16 %143, ptr %5, align 2, !tbaa !8
  %144 = lshr i8 %119, 4
  %145 = and i8 %144, 1
  %146 = zext i8 %145 to i32
  %147 = shl nuw i32 %146, %120
  %148 = trunc i32 %147 to i16
  %149 = or i16 %100, %148
  store i16 %149, ptr %6, align 2, !tbaa !8
  %150 = lshr i8 %119, 5
  %151 = and i8 %150, 1
  %152 = zext i8 %151 to i32
  %153 = shl nuw i32 %152, %120
  %154 = trunc i32 %153 to i16
  %155 = or i16 %106, %154
  store i16 %155, ptr %7, align 2, !tbaa !8
  %156 = lshr i8 %119, 6
  %157 = and i8 %156, 1
  %158 = zext i8 %157 to i32
  %159 = shl nuw i32 %158, %120
  %160 = trunc i32 %159 to i16
  %161 = or i16 %112, %160
  store i16 %161, ptr %8, align 2, !tbaa !8
  %162 = lshr i8 %119, 7
  %163 = zext i8 %162 to i32
  %164 = shl nuw i32 %163, %120
  %165 = trunc i32 %164 to i16
  %166 = or i16 %117, %165
  store i16 %166, ptr %9, align 2, !tbaa !8
  %167 = getelementptr inbounds i8, ptr %12, i64 4
  %168 = load i8, ptr %118, align 1, !tbaa !5
  %169 = add nuw nsw i32 %11, 12
  %170 = and i8 %168, 1
  %171 = zext i8 %170 to i32
  %172 = shl nuw i32 %171, %169
  %173 = trunc i32 %172 to i16
  %174 = or i16 %125, %173
  store i16 %174, ptr %0, align 2, !tbaa !8
  %175 = lshr i8 %168, 1
  %176 = and i8 %175, 1
  %177 = zext i8 %176 to i32
  %178 = shl nuw i32 %177, %169
  %179 = trunc i32 %178 to i16
  %180 = or i16 %131, %179
  store i16 %180, ptr %3, align 2, !tbaa !8
  %181 = lshr i8 %168, 2
  %182 = and i8 %181, 1
  %183 = zext i8 %182 to i32
  %184 = shl nuw i32 %183, %169
  %185 = trunc i32 %184 to i16
  %186 = or i16 %137, %185
  store i16 %186, ptr %4, align 2, !tbaa !8
  %187 = lshr i8 %168, 3
  %188 = and i8 %187, 1
  %189 = zext i8 %188 to i32
  %190 = shl nuw i32 %189, %169
  %191 = trunc i32 %190 to i16
  %192 = or i16 %143, %191
  store i16 %192, ptr %5, align 2, !tbaa !8
  %193 = lshr i8 %168, 4
  %194 = and i8 %193, 1
  %195 = zext i8 %194 to i32
  %196 = shl nuw i32 %195, %169
  %197 = trunc i32 %196 to i16
  %198 = or i16 %149, %197
  store i16 %198, ptr %6, align 2, !tbaa !8
  %199 = lshr i8 %168, 5
  %200 = and i8 %199, 1
  %201 = zext i8 %200 to i32
  %202 = shl nuw i32 %201, %169
  %203 = trunc i32 %202 to i16
  %204 = or i16 %155, %203
  store i16 %204, ptr %7, align 2, !tbaa !8
  %205 = lshr i8 %168, 6
  %206 = and i8 %205, 1
  %207 = zext i8 %206 to i32
  %208 = shl nuw i32 %207, %169
  %209 = trunc i32 %208 to i16
  %210 = or i16 %161, %209
  store i16 %210, ptr %8, align 2, !tbaa !8
  %211 = lshr i8 %168, 7
  %212 = zext i8 %211 to i32
  %213 = shl nuw i32 %212, %169
  %214 = trunc i32 %213 to i16
  %215 = or i16 %166, %214
  store i16 %215, ptr %9, align 2, !tbaa !8
  %216 = add nuw nsw i32 %11, 1
  %217 = icmp eq i32 %216, 4
  br i1 %217, label %218, label %10, !llvm.loop !10

218:                                              ; preds = %10
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #1

; Function Attrs: nofree norecurse nosync nounwind memory(write, argmem: readwrite, inaccessiblemem: none) uwtable
define dso_local void @SaveBytes(ptr nocapture noundef writeonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #2 {
  %3 = getelementptr inbounds [8 x i16], ptr %1, i64 0, i64 1
  %4 = getelementptr inbounds [8 x i16], ptr %1, i64 0, i64 2
  %5 = getelementptr inbounds [8 x i16], ptr %1, i64 0, i64 3
  %6 = getelementptr inbounds [8 x i16], ptr %1, i64 0, i64 4
  %7 = getelementptr inbounds [8 x i16], ptr %1, i64 0, i64 5
  %8 = getelementptr inbounds [8 x i16], ptr %1, i64 0, i64 6
  %9 = getelementptr inbounds [8 x i16], ptr %1, i64 0, i64 7
  br label %10

10:                                               ; preds = %2, %10
  %11 = phi i32 [ 0, %2 ], [ %232, %10 ]
  %12 = phi ptr [ %0, %2 ], [ %231, %10 ]
  %13 = load i16, ptr %1, align 2, !tbaa !8
  %14 = zext i16 %13 to i32
  %15 = lshr i32 %14, %11
  %16 = trunc i32 %15 to i8
  %17 = and i8 %16, 1
  %18 = load i16, ptr %3, align 2, !tbaa !8
  %19 = zext i16 %18 to i32
  %20 = lshr i32 %19, %11
  %21 = trunc i32 %20 to i8
  %22 = shl i8 %21, 1
  %23 = and i8 %22, 2
  %24 = or i8 %17, %23
  %25 = load i16, ptr %4, align 2, !tbaa !8
  %26 = zext i16 %25 to i32
  %27 = lshr i32 %26, %11
  %28 = trunc i32 %27 to i8
  %29 = shl i8 %28, 2
  %30 = and i8 %29, 4
  %31 = or i8 %24, %30
  %32 = load i16, ptr %5, align 2, !tbaa !8
  %33 = zext i16 %32 to i32
  %34 = lshr i32 %33, %11
  %35 = trunc i32 %34 to i8
  %36 = shl i8 %35, 3
  %37 = and i8 %36, 8
  %38 = or i8 %31, %37
  %39 = load i16, ptr %6, align 2, !tbaa !8
  %40 = zext i16 %39 to i32
  %41 = lshr i32 %40, %11
  %42 = trunc i32 %41 to i8
  %43 = shl i8 %42, 4
  %44 = and i8 %43, 16
  %45 = or i8 %38, %44
  %46 = load i16, ptr %7, align 2, !tbaa !8
  %47 = zext i16 %46 to i32
  %48 = lshr i32 %47, %11
  %49 = trunc i32 %48 to i8
  %50 = shl i8 %49, 5
  %51 = and i8 %50, 32
  %52 = or i8 %45, %51
  %53 = load i16, ptr %8, align 2, !tbaa !8
  %54 = zext i16 %53 to i32
  %55 = lshr i32 %54, %11
  %56 = trunc i32 %55 to i8
  %57 = shl i8 %56, 6
  %58 = and i8 %57, 64
  %59 = or i8 %52, %58
  %60 = load i16, ptr %9, align 2, !tbaa !8
  %61 = zext i16 %60 to i32
  %62 = lshr i32 %61, %11
  %63 = trunc i32 %62 to i8
  %64 = shl i8 %63, 7
  %65 = or i8 %59, %64
  %66 = getelementptr inbounds i8, ptr %12, i64 1
  store i8 %65, ptr %12, align 1, !tbaa !5
  %67 = add nuw nsw i32 %11, 4
  %68 = load i16, ptr %1, align 2, !tbaa !8
  %69 = zext i16 %68 to i32
  %70 = lshr i32 %69, %67
  %71 = trunc i32 %70 to i8
  %72 = and i8 %71, 1
  %73 = load i16, ptr %3, align 2, !tbaa !8
  %74 = zext i16 %73 to i32
  %75 = lshr i32 %74, %67
  %76 = trunc i32 %75 to i8
  %77 = shl i8 %76, 1
  %78 = and i8 %77, 2
  %79 = or i8 %72, %78
  %80 = load i16, ptr %4, align 2, !tbaa !8
  %81 = zext i16 %80 to i32
  %82 = lshr i32 %81, %67
  %83 = trunc i32 %82 to i8
  %84 = shl i8 %83, 2
  %85 = and i8 %84, 4
  %86 = or i8 %79, %85
  %87 = load i16, ptr %5, align 2, !tbaa !8
  %88 = zext i16 %87 to i32
  %89 = lshr i32 %88, %67
  %90 = trunc i32 %89 to i8
  %91 = shl i8 %90, 3
  %92 = and i8 %91, 8
  %93 = or i8 %86, %92
  %94 = load i16, ptr %6, align 2, !tbaa !8
  %95 = zext i16 %94 to i32
  %96 = lshr i32 %95, %67
  %97 = trunc i32 %96 to i8
  %98 = shl i8 %97, 4
  %99 = and i8 %98, 16
  %100 = or i8 %93, %99
  %101 = load i16, ptr %7, align 2, !tbaa !8
  %102 = zext i16 %101 to i32
  %103 = lshr i32 %102, %67
  %104 = trunc i32 %103 to i8
  %105 = shl i8 %104, 5
  %106 = and i8 %105, 32
  %107 = or i8 %100, %106
  %108 = load i16, ptr %8, align 2, !tbaa !8
  %109 = zext i16 %108 to i32
  %110 = lshr i32 %109, %67
  %111 = trunc i32 %110 to i8
  %112 = shl i8 %111, 6
  %113 = and i8 %112, 64
  %114 = or i8 %107, %113
  %115 = load i16, ptr %9, align 2, !tbaa !8
  %116 = zext i16 %115 to i32
  %117 = lshr i32 %116, %67
  %118 = trunc i32 %117 to i8
  %119 = shl i8 %118, 7
  %120 = or i8 %114, %119
  %121 = getelementptr inbounds i8, ptr %12, i64 2
  store i8 %120, ptr %66, align 1, !tbaa !5
  %122 = add nuw nsw i32 %11, 8
  %123 = load i16, ptr %1, align 2, !tbaa !8
  %124 = zext i16 %123 to i32
  %125 = lshr i32 %124, %122
  %126 = trunc i32 %125 to i8
  %127 = and i8 %126, 1
  %128 = load i16, ptr %3, align 2, !tbaa !8
  %129 = zext i16 %128 to i32
  %130 = lshr i32 %129, %122
  %131 = trunc i32 %130 to i8
  %132 = shl i8 %131, 1
  %133 = and i8 %132, 2
  %134 = or i8 %127, %133
  %135 = load i16, ptr %4, align 2, !tbaa !8
  %136 = zext i16 %135 to i32
  %137 = lshr i32 %136, %122
  %138 = trunc i32 %137 to i8
  %139 = shl i8 %138, 2
  %140 = and i8 %139, 4
  %141 = or i8 %134, %140
  %142 = load i16, ptr %5, align 2, !tbaa !8
  %143 = zext i16 %142 to i32
  %144 = lshr i32 %143, %122
  %145 = trunc i32 %144 to i8
  %146 = shl i8 %145, 3
  %147 = and i8 %146, 8
  %148 = or i8 %141, %147
  %149 = load i16, ptr %6, align 2, !tbaa !8
  %150 = zext i16 %149 to i32
  %151 = lshr i32 %150, %122
  %152 = trunc i32 %151 to i8
  %153 = shl i8 %152, 4
  %154 = and i8 %153, 16
  %155 = or i8 %148, %154
  %156 = load i16, ptr %7, align 2, !tbaa !8
  %157 = zext i16 %156 to i32
  %158 = lshr i32 %157, %122
  %159 = trunc i32 %158 to i8
  %160 = shl i8 %159, 5
  %161 = and i8 %160, 32
  %162 = or i8 %155, %161
  %163 = load i16, ptr %8, align 2, !tbaa !8
  %164 = zext i16 %163 to i32
  %165 = lshr i32 %164, %122
  %166 = trunc i32 %165 to i8
  %167 = shl i8 %166, 6
  %168 = and i8 %167, 64
  %169 = or i8 %162, %168
  %170 = load i16, ptr %9, align 2, !tbaa !8
  %171 = zext i16 %170 to i32
  %172 = lshr i32 %171, %122
  %173 = trunc i32 %172 to i8
  %174 = shl i8 %173, 7
  %175 = or i8 %169, %174
  %176 = getelementptr inbounds i8, ptr %12, i64 3
  store i8 %175, ptr %121, align 1, !tbaa !5
  %177 = add nuw nsw i32 %11, 12
  %178 = load i16, ptr %1, align 2, !tbaa !8
  %179 = zext i16 %178 to i32
  %180 = lshr i32 %179, %177
  %181 = trunc i32 %180 to i8
  %182 = and i8 %181, 1
  %183 = load i16, ptr %3, align 2, !tbaa !8
  %184 = zext i16 %183 to i32
  %185 = lshr i32 %184, %177
  %186 = trunc i32 %185 to i8
  %187 = shl nuw nsw i8 %186, 1
  %188 = and i8 %187, 2
  %189 = or i8 %182, %188
  %190 = load i16, ptr %4, align 2, !tbaa !8
  %191 = zext i16 %190 to i32
  %192 = lshr i32 %191, %177
  %193 = trunc i32 %192 to i8
  %194 = shl nuw nsw i8 %193, 2
  %195 = and i8 %194, 4
  %196 = or i8 %189, %195
  %197 = load i16, ptr %5, align 2, !tbaa !8
  %198 = zext i16 %197 to i32
  %199 = lshr i32 %198, %177
  %200 = trunc i32 %199 to i8
  %201 = shl nuw nsw i8 %200, 3
  %202 = and i8 %201, 8
  %203 = or i8 %196, %202
  %204 = load i16, ptr %6, align 2, !tbaa !8
  %205 = zext i16 %204 to i32
  %206 = lshr i32 %205, %177
  %207 = trunc i32 %206 to i8
  %208 = shl nuw i8 %207, 4
  %209 = and i8 %208, 16
  %210 = or i8 %203, %209
  %211 = load i16, ptr %7, align 2, !tbaa !8
  %212 = zext i16 %211 to i32
  %213 = lshr i32 %212, %177
  %214 = trunc i32 %213 to i8
  %215 = shl i8 %214, 5
  %216 = and i8 %215, 32
  %217 = or i8 %210, %216
  %218 = load i16, ptr %8, align 2, !tbaa !8
  %219 = zext i16 %218 to i32
  %220 = lshr i32 %219, %177
  %221 = trunc i32 %220 to i8
  %222 = shl i8 %221, 6
  %223 = and i8 %222, 64
  %224 = or i8 %217, %223
  %225 = load i16, ptr %9, align 2, !tbaa !8
  %226 = zext i16 %225 to i32
  %227 = lshr i32 %226, %177
  %228 = trunc i32 %227 to i8
  %229 = shl i8 %228, 7
  %230 = or i8 %224, %229
  %231 = getelementptr inbounds i8, ptr %12, i64 4
  store i8 %230, ptr %176, align 1, !tbaa !5
  %232 = add nuw nsw i32 %11, 1
  %233 = icmp eq i32 %232, 4
  br i1 %233, label %234, label %10, !llvm.loop !12

234:                                              ; preds = %10
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define dso_local void @SubBytes(ptr nocapture noundef %0, i32 noundef %1) local_unnamed_addr #3 {
  %3 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 7
  %4 = load i16, ptr %3, align 2, !tbaa !8
  %5 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 6
  %6 = load i16, ptr %5, align 2, !tbaa !8
  %7 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 5
  %8 = load i16, ptr %7, align 2, !tbaa !8
  %9 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 4
  %10 = load i16, ptr %9, align 2, !tbaa !8
  %11 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 3
  %12 = load i16, ptr %11, align 2, !tbaa !8
  %13 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 2
  %14 = load i16, ptr %13, align 2, !tbaa !8
  %15 = getelementptr inbounds [8 x i16], ptr %0, i64 0, i64 1
  %16 = load i16, ptr %15, align 2, !tbaa !8
  %17 = load i16, ptr %0, align 2, !tbaa !8
  %18 = xor i16 %10, %4
  %19 = xor i16 %14, %4
  %20 = xor i16 %16, %4
  %21 = xor i16 %14, %10
  %22 = xor i16 %16, %12
  %23 = xor i16 %22, %18
  %24 = xor i16 %8, %6
  %25 = xor i16 %23, %17
  %26 = xor i16 %17, %24
  %27 = xor i16 %23, %24
  %28 = xor i16 %14, %6
  %29 = xor i16 %14, %8
  %30 = xor i16 %20, %21
  %31 = xor i16 %22, %28
  %32 = xor i16 %22, %29
  %33 = xor i16 %26, %32
  %34 = xor i16 %26, %10
  %35 = xor i16 %26, %4
  %36 = xor i16 %26, %16
  %37 = xor i16 %36, %19
  %38 = xor i16 %29, %18
  %39 = and i16 %30, %23
  %40 = and i16 %32, %20
  %41 = and i16 %31, %18
  %42 = and i16 %38, %21
  %43 = xor i16 %41, %42
  %44 = and i16 %27, %19
  %45 = xor i16 %44, %41
  %46 = and i16 %37, %25
  %47 = xor i16 %28, %46
  %48 = xor i16 %47, %23
  %49 = xor i16 %48, %39
  %50 = xor i16 %49, %43
  %51 = and i16 %34, %17
  %52 = xor i16 %19, %51
  %53 = xor i16 %52, %27
  %54 = xor i16 %53, %39
  %55 = xor i16 %54, %45
  %56 = or i16 %32, %20
  %57 = and i16 %36, %26
  %58 = xor i16 %57, %56
  %59 = xor i16 %58, %43
  %60 = and i16 %35, %33
  %61 = xor i16 %40, %60
  %62 = xor i16 %61, %4
  %63 = xor i16 %62, %32
  %64 = xor i16 %63, %45
  %65 = and i16 %50, %59
  %66 = xor i16 %50, %55
  %67 = xor i16 %65, %64
  %68 = and i16 %67, %66
  %69 = xor i16 %68, %55
  %70 = and i16 %50, %64
  %71 = or i16 %70, %55
  %72 = xor i16 %50, %71
  %73 = xor i16 %72, %65
  %74 = xor i16 %64, %59
  %75 = xor i16 %65, %55
  %76 = and i16 %75, %74
  %77 = xor i16 %76, %64
  %78 = and i16 %55, %59
  %79 = or i16 %78, %64
  %80 = xor i16 %79, %59
  %81 = xor i16 %80, %65
  %82 = xor i16 %72, %80
  %83 = xor i16 %69, %77
  %84 = xor i16 %69, %73
  %85 = xor i16 %77, %81
  %86 = xor i16 %83, %82
  %87 = and i16 %85, %23
  %88 = and i16 %81, %25
  %89 = and i16 %77, %17
  %90 = and i16 %84, %32
  %91 = and i16 %73, %26
  %92 = and i16 %69, %33
  %93 = and i16 %83, %31
  %94 = and i16 %86, %38
  %95 = and i16 %82, %27
  %96 = and i16 %85, %30
  %97 = and i16 %81, %37
  %98 = and i16 %77, %34
  %99 = and i16 %84, %20
  %100 = and i16 %73, %36
  %101 = and i16 %69, %35
  %102 = and i16 %83, %18
  %103 = and i16 %86, %21
  %104 = and i16 %82, %19
  %105 = xor i16 %103, %102
  %106 = xor i16 %91, %97
  %107 = xor i16 %87, %89
  %108 = xor i16 %96, %88
  %109 = xor i16 %95, %99
  %110 = xor i16 %102, %90
  %111 = xor i16 %110, %103
  %112 = xor i16 %108, %87
  %113 = xor i16 %92, %100
  %114 = xor i16 %94, %93
  %115 = xor i16 %94, %109
  %116 = xor i16 %107, %101
  %117 = xor i16 %89, %92
  %118 = xor i16 %105, %97
  %119 = xor i16 %118, %114
  %120 = xor i16 %104, %102
  %121 = xor i16 %120, %93
  %122 = xor i16 %121, %109
  %123 = xor i16 %117, %106
  %124 = xor i16 %106, %98
  %125 = xor i16 %124, %111
  %126 = xor i16 %113, %91
  %127 = xor i16 %126, %115
  %128 = xor i16 %113, %99
  %129 = xor i16 %128, %107
  %130 = xor i16 %111, %106
  %131 = xor i16 %130, %96
  %132 = xor i16 %119, %112
  %133 = xor i16 %122, %116
  %134 = xor i16 %123, %108
  %135 = xor i16 %125, %116
  %136 = xor i16 %127, %105
  %137 = xor i16 %129, %111
  %138 = insertelement <8 x i16> poison, i16 %137, i64 0
  %139 = insertelement <8 x i16> %138, i16 %136, i64 1
  %140 = insertelement <8 x i16> %139, i16 %135, i64 2
  %141 = insertelement <8 x i16> %140, i16 %134, i64 3
  %142 = insertelement <8 x i16> %141, i16 %130, i64 4
  %143 = insertelement <8 x i16> %142, i16 %133, i64 5
  %144 = insertelement <8 x i16> %143, i16 %132, i64 6
  %145 = insertelement <8 x i16> %144, i16 %131, i64 7
  %146 = insertelement <8 x i16> <i16 -1, i16 -1, i16 poison, i16 poison, i16 poison, i16 -1, i16 -1, i16 poison>, i16 %115, i64 2
  %147 = insertelement <8 x i16> %146, i16 %105, i64 3
  %148 = insertelement <8 x i16> %147, i16 %112, i64 4
  %149 = insertelement <8 x i16> %148, i16 %114, i64 7
  %150 = xor <8 x i16> %145, %149
  store <8 x i16> %150, ptr %0, align 2, !tbaa !8
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local void @ShiftRows(ptr nocapture noundef %0) local_unnamed_addr #4 {
  %2 = load <8 x i16>, ptr %0, align 2, !tbaa !8
  %3 = and <8 x i16> %2, <i16 15, i16 15, i16 15, i16 15, i16 15, i16 15, i16 15, i16 15>
  %4 = shl <8 x i16> %2, <i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3>
  %5 = and <8 x i16> %4, <i16 128, i16 128, i16 128, i16 128, i16 128, i16 128, i16 128, i16 128>
  %6 = or <8 x i16> %5, %3
  %7 = lshr <8 x i16> %2, <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>
  %8 = and <8 x i16> %7, <i16 112, i16 112, i16 112, i16 112, i16 112, i16 112, i16 112, i16 112>
  %9 = or <8 x i16> %6, %8
  %10 = shl <8 x i16> %2, <i16 2, i16 2, i16 2, i16 2, i16 2, i16 2, i16 2, i16 2>
  %11 = and <8 x i16> %10, <i16 3072, i16 3072, i16 3072, i16 3072, i16 3072, i16 3072, i16 3072, i16 3072>
  %12 = or <8 x i16> %9, %11
  %13 = lshr <8 x i16> %2, <i16 2, i16 2, i16 2, i16 2, i16 2, i16 2, i16 2, i16 2>
  %14 = and <8 x i16> %13, <i16 768, i16 768, i16 768, i16 768, i16 768, i16 768, i16 768, i16 768>
  %15 = or <8 x i16> %12, %14
  %16 = shl <8 x i16> %2, <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>
  %17 = and <8 x i16> %16, <i16 -8192, i16 -8192, i16 -8192, i16 -8192, i16 -8192, i16 -8192, i16 -8192, i16 -8192>
  %18 = or <8 x i16> %15, %17
  %19 = lshr <8 x i16> %2, <i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3, i16 3>
  %20 = and <8 x i16> %19, <i16 4096, i16 4096, i16 4096, i16 4096, i16 4096, i16 4096, i16 4096, i16 4096>
  %21 = or <8 x i16> %18, %20
  store <8 x i16> %21, ptr %0, align 2, !tbaa !8
  ret void
}

attributes #0 = { nofree nosync nounwind memory(read, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #2 = { nofree norecurse nosync nounwind memory(write, argmem: readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git 7599a5138d3c6b1b3e4e4f4ee175c3922bf6a87e)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{!9, !9, i64 0}
!9 = !{!"short", !6, i64 0}
!10 = distinct !{!10, !11}
!11 = !{!"llvm.loop.mustprogress"}
!12 = distinct !{!12, !11}