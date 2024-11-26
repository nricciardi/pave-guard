import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { CreateTemperatureTelemetryDto } from '../dto/create-temperature-telemetry.dto';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { RainTelemetryService } from '../services/rain-telemetry/rain-telemetry.service';
import { CreateRainTelemetryDto } from '../dto/create-rain-telemetry.dto';


@ObjectType()
export class RainTelemetryQuery extends TelemetryQuery {

  @Field()
  litres: number;
}


@Resolver(() => RainTelemetryQuery)
export class RainTelemetryResolver {
  constructor(
    private readonly rainTelemetryService: RainTelemetryService,
  ) {}

  @Query(() => [RainTelemetryQuery])
  @UseGuards(AdminGuard)
  async rainTelemetries() {
    return this.rainTelemetryService.findAll();
  }

  @Mutation(() => RainTelemetryQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createRainTelemetry(
    @Args() input: CreateRainTelemetryDto,
  ) {   

    return this.rainTelemetryService.create(input);
  }
}

