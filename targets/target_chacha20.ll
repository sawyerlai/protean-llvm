; ModuleID = 'target_chacha20.c'
source_filename = "target_chacha20.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local i32 @br_chacha20_ct_run(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i32 noundef %2, ptr nocapture noundef %3, i64 noundef %4) local_unnamed_addr #0 {
  %6 = alloca [64 x i8], align 16
  %7 = load i32, ptr %0, align 1
  %8 = getelementptr inbounds i8, ptr %0, i64 4
  %9 = load i32, ptr %8, align 1
  %10 = getelementptr inbounds i8, ptr %0, i64 8
  %11 = load i32, ptr %10, align 1
  %12 = getelementptr inbounds i8, ptr %0, i64 12
  %13 = load i32, ptr %12, align 1
  %14 = getelementptr inbounds i8, ptr %0, i64 16
  %15 = load i32, ptr %14, align 1
  %16 = getelementptr inbounds i8, ptr %0, i64 20
  %17 = load i32, ptr %16, align 1
  %18 = getelementptr inbounds i8, ptr %0, i64 24
  %19 = load i32, ptr %18, align 1
  %20 = getelementptr inbounds i8, ptr %0, i64 28
  %21 = load i32, ptr %20, align 1
  %22 = load i32, ptr %1, align 1
  %23 = getelementptr inbounds i8, ptr %1, i64 4
  %24 = load i32, ptr %23, align 1
  %25 = getelementptr inbounds i8, ptr %1, i64 8
  %26 = load i32, ptr %25, align 1
  %27 = icmp eq i64 %4, 0
  br i1 %27, label %392, label %28

28:                                               ; preds = %5
  %29 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 48
  %30 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 49
  %31 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 50
  %32 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 51
  %33 = getelementptr inbounds i8, ptr %6, i64 1
  %34 = getelementptr inbounds i8, ptr %6, i64 2
  %35 = getelementptr inbounds i8, ptr %6, i64 3
  %36 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 4
  %37 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 5
  %38 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 6
  %39 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 7
  %40 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 8
  %41 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 9
  %42 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 10
  %43 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 11
  %44 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 12
  %45 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 13
  %46 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 14
  %47 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 15
  %48 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 16
  %49 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 17
  %50 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 18
  %51 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 19
  %52 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 20
  %53 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 21
  %54 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 22
  %55 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 23
  %56 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 24
  %57 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 25
  %58 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 26
  %59 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 27
  %60 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 28
  %61 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 29
  %62 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 30
  %63 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 31
  %64 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 32
  %65 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 33
  %66 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 34
  %67 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 35
  %68 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 36
  %69 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 37
  %70 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 38
  %71 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 39
  %72 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 40
  %73 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 41
  %74 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 42
  %75 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 43
  %76 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 44
  %77 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 45
  %78 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 46
  %79 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 47
  %80 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 52
  %81 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 53
  %82 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 54
  %83 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 55
  %84 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 56
  %85 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 57
  %86 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 58
  %87 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 59
  %88 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 60
  %89 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 61
  %90 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 62
  %91 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 63
  br label %92

92:                                               ; preds = %28, %387
  %93 = phi i32 [ %2, %28 ], [ %390, %387 ]
  %94 = phi ptr [ %3, %28 ], [ %388, %387 ]
  %95 = phi i64 [ %4, %28 ], [ %389, %387 ]
  call void @llvm.lifetime.start.p0(i64 64, ptr nonnull %6) #3
  br label %262

96:                                               ; preds = %262
  %97 = add i32 %334, 1634760805
  %98 = trunc i32 %97 to i8
  store i8 %98, ptr %6, align 16, !tbaa !5
  %99 = lshr i32 %97, 8
  %100 = trunc i32 %99 to i8
  store i8 %100, ptr %33, align 1, !tbaa !5
  %101 = lshr i32 %97, 16
  %102 = trunc i32 %101 to i8
  store i8 %102, ptr %34, align 2, !tbaa !5
  %103 = lshr i32 %97, 24
  %104 = trunc i32 %103 to i8
  store i8 %104, ptr %35, align 1, !tbaa !5
  %105 = add i32 %346, 857760878
  %106 = trunc i32 %105 to i8
  store i8 %106, ptr %36, align 4, !tbaa !5
  %107 = lshr i32 %105, 8
  %108 = trunc i32 %107 to i8
  store i8 %108, ptr %37, align 1, !tbaa !5
  %109 = lshr i32 %105, 16
  %110 = trunc i32 %109 to i8
  store i8 %110, ptr %38, align 2, !tbaa !5
  %111 = lshr i32 %105, 24
  %112 = trunc i32 %111 to i8
  store i8 %112, ptr %39, align 1, !tbaa !5
  %113 = add i32 %358, 2036477234
  %114 = trunc i32 %113 to i8
  store i8 %114, ptr %40, align 8, !tbaa !5
  %115 = lshr i32 %113, 8
  %116 = trunc i32 %115 to i8
  store i8 %116, ptr %41, align 1, !tbaa !5
  %117 = lshr i32 %113, 16
  %118 = trunc i32 %117 to i8
  store i8 %118, ptr %42, align 2, !tbaa !5
  %119 = lshr i32 %113, 24
  %120 = trunc i32 %119 to i8
  store i8 %120, ptr %43, align 1, !tbaa !5
  %121 = add i32 %370, 1797285236
  %122 = trunc i32 %121 to i8
  store i8 %122, ptr %44, align 4, !tbaa !5
  %123 = lshr i32 %121, 8
  %124 = trunc i32 %123 to i8
  store i8 %124, ptr %45, align 1, !tbaa !5
  %125 = lshr i32 %121, 16
  %126 = trunc i32 %125 to i8
  store i8 %126, ptr %46, align 2, !tbaa !5
  %127 = lshr i32 %121, 24
  %128 = trunc i32 %127 to i8
  store i8 %128, ptr %47, align 1, !tbaa !5
  %129 = add i32 %7, %375
  %130 = trunc i32 %129 to i8
  store i8 %130, ptr %48, align 16, !tbaa !5
  %131 = lshr i32 %129, 8
  %132 = trunc i32 %131 to i8
  store i8 %132, ptr %49, align 1, !tbaa !5
  %133 = lshr i32 %129, 16
  %134 = trunc i32 %133 to i8
  store i8 %134, ptr %50, align 2, !tbaa !5
  %135 = lshr i32 %129, 24
  %136 = trunc i32 %135 to i8
  store i8 %136, ptr %51, align 1, !tbaa !5
  %137 = add i32 %9, %339
  %138 = trunc i32 %137 to i8
  store i8 %138, ptr %52, align 4, !tbaa !5
  %139 = lshr i32 %137, 8
  %140 = trunc i32 %139 to i8
  store i8 %140, ptr %53, align 1, !tbaa !5
  %141 = lshr i32 %137, 16
  %142 = trunc i32 %141 to i8
  store i8 %142, ptr %54, align 2, !tbaa !5
  %143 = lshr i32 %137, 24
  %144 = trunc i32 %143 to i8
  store i8 %144, ptr %55, align 1, !tbaa !5
  %145 = add i32 %11, %351
  %146 = trunc i32 %145 to i8
  store i8 %146, ptr %56, align 8, !tbaa !5
  %147 = lshr i32 %145, 8
  %148 = trunc i32 %147 to i8
  store i8 %148, ptr %57, align 1, !tbaa !5
  %149 = lshr i32 %145, 16
  %150 = trunc i32 %149 to i8
  store i8 %150, ptr %58, align 2, !tbaa !5
  %151 = lshr i32 %145, 24
  %152 = trunc i32 %151 to i8
  store i8 %152, ptr %59, align 1, !tbaa !5
  %153 = add i32 %13, %363
  %154 = trunc i32 %153 to i8
  store i8 %154, ptr %60, align 4, !tbaa !5
  %155 = lshr i32 %153, 8
  %156 = trunc i32 %155 to i8
  store i8 %156, ptr %61, align 1, !tbaa !5
  %157 = lshr i32 %153, 16
  %158 = trunc i32 %157 to i8
  store i8 %158, ptr %62, align 2, !tbaa !5
  %159 = lshr i32 %153, 24
  %160 = trunc i32 %159 to i8
  store i8 %160, ptr %63, align 1, !tbaa !5
  %161 = add i32 %15, %361
  %162 = trunc i32 %161 to i8
  store i8 %162, ptr %64, align 16, !tbaa !5
  %163 = lshr i32 %161, 8
  %164 = trunc i32 %163 to i8
  store i8 %164, ptr %65, align 1, !tbaa !5
  %165 = lshr i32 %161, 16
  %166 = trunc i32 %165 to i8
  store i8 %166, ptr %66, align 2, !tbaa !5
  %167 = lshr i32 %161, 24
  %168 = trunc i32 %167 to i8
  store i8 %168, ptr %67, align 1, !tbaa !5
  %169 = add i32 %17, %373
  %170 = trunc i32 %169 to i8
  store i8 %170, ptr %68, align 4, !tbaa !5
  %171 = lshr i32 %169, 8
  %172 = trunc i32 %171 to i8
  store i8 %172, ptr %69, align 1, !tbaa !5
  %173 = lshr i32 %169, 16
  %174 = trunc i32 %173 to i8
  store i8 %174, ptr %70, align 2, !tbaa !5
  %175 = lshr i32 %169, 24
  %176 = trunc i32 %175 to i8
  store i8 %176, ptr %71, align 1, !tbaa !5
  %177 = add i32 %19, %337
  %178 = trunc i32 %177 to i8
  store i8 %178, ptr %72, align 8, !tbaa !5
  %179 = lshr i32 %177, 8
  %180 = trunc i32 %179 to i8
  store i8 %180, ptr %73, align 1, !tbaa !5
  %181 = lshr i32 %177, 16
  %182 = trunc i32 %181 to i8
  store i8 %182, ptr %74, align 2, !tbaa !5
  %183 = lshr i32 %177, 24
  %184 = trunc i32 %183 to i8
  store i8 %184, ptr %75, align 1, !tbaa !5
  %185 = add i32 %21, %349
  %186 = trunc i32 %185 to i8
  store i8 %186, ptr %76, align 4, !tbaa !5
  %187 = lshr i32 %185, 8
  %188 = trunc i32 %187 to i8
  store i8 %188, ptr %77, align 1, !tbaa !5
  %189 = lshr i32 %185, 16
  %190 = trunc i32 %189 to i8
  store i8 %190, ptr %78, align 2, !tbaa !5
  %191 = lshr i32 %185, 24
  %192 = trunc i32 %191 to i8
  store i8 %192, ptr %79, align 1, !tbaa !5
  %193 = add i32 %348, %93
  %194 = trunc i32 %193 to i8
  store i8 %194, ptr %29, align 16, !tbaa !5
  %195 = lshr i32 %193, 8
  %196 = trunc i32 %195 to i8
  store i8 %196, ptr %30, align 1, !tbaa !5
  %197 = lshr i32 %193, 16
  %198 = trunc i32 %197 to i8
  store i8 %198, ptr %31, align 2, !tbaa !5
  %199 = lshr i32 %193, 24
  %200 = trunc i32 %199 to i8
  store i8 %200, ptr %32, align 1, !tbaa !5
  %201 = add i32 %22, %360
  %202 = trunc i32 %201 to i8
  store i8 %202, ptr %80, align 4, !tbaa !5
  %203 = lshr i32 %201, 8
  %204 = trunc i32 %203 to i8
  store i8 %204, ptr %81, align 1, !tbaa !5
  %205 = lshr i32 %201, 16
  %206 = trunc i32 %205 to i8
  store i8 %206, ptr %82, align 2, !tbaa !5
  %207 = lshr i32 %201, 24
  %208 = trunc i32 %207 to i8
  store i8 %208, ptr %83, align 1, !tbaa !5
  %209 = add i32 %24, %372
  %210 = trunc i32 %209 to i8
  store i8 %210, ptr %84, align 8, !tbaa !5
  %211 = lshr i32 %209, 8
  %212 = trunc i32 %211 to i8
  store i8 %212, ptr %85, align 1, !tbaa !5
  %213 = lshr i32 %209, 16
  %214 = trunc i32 %213 to i8
  store i8 %214, ptr %86, align 2, !tbaa !5
  %215 = lshr i32 %209, 24
  %216 = trunc i32 %215 to i8
  store i8 %216, ptr %87, align 1, !tbaa !5
  %217 = add i32 %26, %336
  %218 = trunc i32 %217 to i8
  store i8 %218, ptr %88, align 4, !tbaa !5
  %219 = lshr i32 %217, 8
  %220 = trunc i32 %219 to i8
  store i8 %220, ptr %89, align 1, !tbaa !5
  %221 = lshr i32 %217, 16
  %222 = trunc i32 %221 to i8
  store i8 %222, ptr %90, align 2, !tbaa !5
  %223 = lshr i32 %217, 24
  %224 = trunc i32 %223 to i8
  store i8 %224, ptr %91, align 1, !tbaa !5
  %225 = tail call i64 @llvm.umin.i64(i64 %95, i64 64)
  %226 = tail call i64 @llvm.umax.i64(i64 %225, i64 1)
  %227 = icmp ult i64 %226, 8
  br i1 %227, label %260, label %228

228:                                              ; preds = %96
  %229 = icmp ult i64 %226, 16
  br i1 %229, label %246, label %230

230:                                              ; preds = %228
  %231 = and i64 %226, 112
  br label %232

232:                                              ; preds = %232, %230
  %233 = phi i64 [ 0, %230 ], [ %239, %232 ]
  %234 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 %233
  %235 = load <16 x i8>, ptr %234, align 16, !tbaa !5
  %236 = getelementptr inbounds i8, ptr %94, i64 %233
  %237 = load <16 x i8>, ptr %236, align 1, !tbaa !5
  %238 = xor <16 x i8> %237, %235
  store <16 x i8> %238, ptr %236, align 1, !tbaa !5
  %239 = add nuw i64 %233, 16
  %240 = icmp eq i64 %239, %231
  br i1 %240, label %241, label %232, !llvm.loop !8

241:                                              ; preds = %232
  %242 = icmp eq i64 %226, %231
  br i1 %242, label %387, label %243

243:                                              ; preds = %241
  %244 = and i64 %226, 8
  %245 = icmp eq i64 %244, 0
  br i1 %245, label %260, label %246

246:                                              ; preds = %228, %243
  %247 = phi i64 [ %231, %243 ], [ 0, %228 ]
  %248 = and i64 %226, 120
  br label %249

249:                                              ; preds = %249, %246
  %250 = phi i64 [ %247, %246 ], [ %256, %249 ]
  %251 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 %250
  %252 = load <8 x i8>, ptr %251, align 8, !tbaa !5
  %253 = getelementptr inbounds i8, ptr %94, i64 %250
  %254 = load <8 x i8>, ptr %253, align 1, !tbaa !5
  %255 = xor <8 x i8> %254, %252
  store <8 x i8> %255, ptr %253, align 1, !tbaa !5
  %256 = add nuw i64 %250, 8
  %257 = icmp eq i64 %256, %248
  br i1 %257, label %258, label %249, !llvm.loop !12

258:                                              ; preds = %249
  %259 = icmp eq i64 %226, %248
  br i1 %259, label %387, label %260

260:                                              ; preds = %96, %243, %258
  %261 = phi i64 [ 0, %96 ], [ %231, %243 ], [ %248, %258 ]
  br label %378

262:                                              ; preds = %92, %262
  %263 = phi i32 [ 0, %92 ], [ %376, %262 ]
  %264 = phi i32 [ %7, %92 ], [ %375, %262 ]
  %265 = phi i32 [ 1634760805, %92 ], [ %334, %262 ]
  %266 = phi i32 [ %93, %92 ], [ %348, %262 ]
  %267 = phi i32 [ %15, %92 ], [ %361, %262 ]
  %268 = phi i32 [ %9, %92 ], [ %339, %262 ]
  %269 = phi i32 [ 857760878, %92 ], [ %346, %262 ]
  %270 = phi i32 [ %22, %92 ], [ %360, %262 ]
  %271 = phi i32 [ %17, %92 ], [ %373, %262 ]
  %272 = phi i32 [ %11, %92 ], [ %351, %262 ]
  %273 = phi i32 [ 2036477234, %92 ], [ %358, %262 ]
  %274 = phi i32 [ %24, %92 ], [ %372, %262 ]
  %275 = phi i32 [ %19, %92 ], [ %337, %262 ]
  %276 = phi i32 [ %13, %92 ], [ %363, %262 ]
  %277 = phi i32 [ 1797285236, %92 ], [ %370, %262 ]
  %278 = phi i32 [ %26, %92 ], [ %336, %262 ]
  %279 = phi i32 [ %21, %92 ], [ %349, %262 ]
  %280 = add i32 %265, %264
  %281 = xor i32 %266, %280
  %282 = tail call i32 @llvm.fshl.i32(i32 %281, i32 %281, i32 16)
  %283 = add i32 %267, %282
  %284 = xor i32 %283, %264
  %285 = tail call i32 @llvm.fshl.i32(i32 %284, i32 %284, i32 12)
  %286 = add i32 %285, %280
  %287 = xor i32 %286, %282
  %288 = tail call i32 @llvm.fshl.i32(i32 %287, i32 %287, i32 8)
  %289 = add i32 %288, %283
  %290 = xor i32 %289, %285
  %291 = tail call i32 @llvm.fshl.i32(i32 %290, i32 %290, i32 7)
  %292 = add i32 %269, %268
  %293 = xor i32 %270, %292
  %294 = tail call i32 @llvm.fshl.i32(i32 %293, i32 %293, i32 16)
  %295 = add i32 %271, %294
  %296 = xor i32 %295, %268
  %297 = tail call i32 @llvm.fshl.i32(i32 %296, i32 %296, i32 12)
  %298 = add i32 %297, %292
  %299 = xor i32 %298, %294
  %300 = tail call i32 @llvm.fshl.i32(i32 %299, i32 %299, i32 8)
  %301 = add i32 %300, %295
  %302 = xor i32 %301, %297
  %303 = tail call i32 @llvm.fshl.i32(i32 %302, i32 %302, i32 7)
  %304 = add i32 %273, %272
  %305 = xor i32 %274, %304
  %306 = tail call i32 @llvm.fshl.i32(i32 %305, i32 %305, i32 16)
  %307 = add i32 %275, %306
  %308 = xor i32 %307, %272
  %309 = tail call i32 @llvm.fshl.i32(i32 %308, i32 %308, i32 12)
  %310 = add i32 %309, %304
  %311 = xor i32 %310, %306
  %312 = tail call i32 @llvm.fshl.i32(i32 %311, i32 %311, i32 8)
  %313 = add i32 %312, %307
  %314 = xor i32 %313, %309
  %315 = tail call i32 @llvm.fshl.i32(i32 %314, i32 %314, i32 7)
  %316 = add i32 %277, %276
  %317 = xor i32 %278, %316
  %318 = tail call i32 @llvm.fshl.i32(i32 %317, i32 %317, i32 16)
  %319 = add i32 %279, %318
  %320 = xor i32 %319, %276
  %321 = tail call i32 @llvm.fshl.i32(i32 %320, i32 %320, i32 12)
  %322 = add i32 %321, %316
  %323 = xor i32 %322, %318
  %324 = tail call i32 @llvm.fshl.i32(i32 %323, i32 %323, i32 8)
  %325 = add i32 %324, %319
  %326 = xor i32 %325, %321
  %327 = tail call i32 @llvm.fshl.i32(i32 %326, i32 %326, i32 7)
  %328 = add i32 %303, %286
  %329 = xor i32 %324, %328
  %330 = tail call i32 @llvm.fshl.i32(i32 %329, i32 %329, i32 16)
  %331 = add i32 %330, %313
  %332 = xor i32 %331, %303
  %333 = tail call i32 @llvm.fshl.i32(i32 %332, i32 %332, i32 12)
  %334 = add i32 %333, %328
  %335 = xor i32 %334, %330
  %336 = tail call i32 @llvm.fshl.i32(i32 %335, i32 %335, i32 8)
  %337 = add i32 %336, %331
  %338 = xor i32 %337, %333
  %339 = tail call i32 @llvm.fshl.i32(i32 %338, i32 %338, i32 7)
  %340 = add i32 %315, %298
  %341 = xor i32 %340, %288
  %342 = tail call i32 @llvm.fshl.i32(i32 %341, i32 %341, i32 16)
  %343 = add i32 %325, %342
  %344 = xor i32 %343, %315
  %345 = tail call i32 @llvm.fshl.i32(i32 %344, i32 %344, i32 12)
  %346 = add i32 %345, %340
  %347 = xor i32 %346, %342
  %348 = tail call i32 @llvm.fshl.i32(i32 %347, i32 %347, i32 8)
  %349 = add i32 %348, %343
  %350 = xor i32 %349, %345
  %351 = tail call i32 @llvm.fshl.i32(i32 %350, i32 %350, i32 7)
  %352 = add i32 %327, %310
  %353 = xor i32 %352, %300
  %354 = tail call i32 @llvm.fshl.i32(i32 %353, i32 %353, i32 16)
  %355 = add i32 %354, %289
  %356 = xor i32 %355, %327
  %357 = tail call i32 @llvm.fshl.i32(i32 %356, i32 %356, i32 12)
  %358 = add i32 %357, %352
  %359 = xor i32 %358, %354
  %360 = tail call i32 @llvm.fshl.i32(i32 %359, i32 %359, i32 8)
  %361 = add i32 %360, %355
  %362 = xor i32 %361, %357
  %363 = tail call i32 @llvm.fshl.i32(i32 %362, i32 %362, i32 7)
  %364 = add i32 %322, %291
  %365 = xor i32 %364, %312
  %366 = tail call i32 @llvm.fshl.i32(i32 %365, i32 %365, i32 16)
  %367 = add i32 %366, %301
  %368 = xor i32 %367, %291
  %369 = tail call i32 @llvm.fshl.i32(i32 %368, i32 %368, i32 12)
  %370 = add i32 %369, %364
  %371 = xor i32 %370, %366
  %372 = tail call i32 @llvm.fshl.i32(i32 %371, i32 %371, i32 8)
  %373 = add i32 %372, %367
  %374 = xor i32 %373, %369
  %375 = tail call i32 @llvm.fshl.i32(i32 %374, i32 %374, i32 7)
  %376 = add nuw nsw i32 %263, 1
  %377 = icmp eq i32 %376, 10
  br i1 %377, label %96, label %262, !llvm.loop !13

378:                                              ; preds = %260, %378
  %379 = phi i64 [ %385, %378 ], [ %261, %260 ]
  %380 = getelementptr inbounds [64 x i8], ptr %6, i64 0, i64 %379
  %381 = load i8, ptr %380, align 1, !tbaa !5
  %382 = getelementptr inbounds i8, ptr %94, i64 %379
  %383 = load i8, ptr %382, align 1, !tbaa !5
  %384 = xor i8 %383, %381
  store i8 %384, ptr %382, align 1, !tbaa !5
  %385 = add nuw nsw i64 %379, 1
  %386 = icmp eq i64 %385, %226
  br i1 %386, label %387, label %378, !llvm.loop !14

387:                                              ; preds = %378, %258, %241
  %388 = getelementptr inbounds i8, ptr %94, i64 %225
  %389 = sub i64 %95, %225
  %390 = add i32 %93, 1
  call void @llvm.lifetime.end.p0(i64 64, ptr nonnull %6) #3
  %391 = icmp eq i64 %389, 0
  br i1 %391, label %392, label %92, !llvm.loop !15

392:                                              ; preds = %387, %5
  %393 = phi i32 [ %2, %5 ], [ %390, %387 ]
  ret i32 %393
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umin.i64(i64, i64) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fshl.i32(i32, i32, i32) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #2

attributes #0 = { nofree nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nounwind }

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
!8 = distinct !{!8, !9, !10, !11}
!9 = !{!"llvm.loop.mustprogress"}
!10 = !{!"llvm.loop.isvectorized", i32 1}
!11 = !{!"llvm.loop.unroll.runtime.disable"}
!12 = distinct !{!12, !9, !10, !11}
!13 = distinct !{!13, !9}
!14 = distinct !{!14, !9, !11, !10}
!15 = distinct !{!15, !9}
