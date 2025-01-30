import { Args, Mutation, Query, Resolver } from "@nestjs/graphql";
import { PredictionDto } from "../dto/prediction.dto";
import { ModelService } from "../services/model/model.service";
import { AdminGuard } from "src/modules/user/guards/admin/admin.guard";
import { UseGuards } from "@nestjs/common";


@Resolver(() => PredictionDto)
export class ModelProxyResolver {
  constructor(
    private readonly modelService: ModelService,
  ) {}

  @Query(() => [PredictionDto])
  @UseGuards(AdminGuard)
  async predictions() {
    return this.modelService.predictions();
  }

  @Mutation(() => PredictionDto)
  @UseGuards(AdminGuard)
  async createPrediction(
    @Args() input: PredictionDto,
  ) {

    return this.modelService.createPrediction(input);
  }
}
